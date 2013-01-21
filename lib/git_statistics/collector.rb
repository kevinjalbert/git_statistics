module GitStatistics
  class Collector

    attr_accessor :repo, :repo_path, :commits_path, :commits, :verbose

    def initialize(verbose, limit, fresh, pretty)
      @verbose = verbose
      @repo = Utilities.get_repository

      raise "No Git repository found" if @repo.nil?

      @repo_path = File.expand_path("..", @repo.path) + File::Separator
      @commits_path = @repo_path + ".git_statistics" + File::Separator
      @commits = Commits.new(@commits_path, fresh, limit, pretty)
    end

    def collect(branch, time_since = "", time_until = "")
      # Create pipe for git log to acquire branches
      pipe = Pipe.new("git --no-pager branch --no-color")

      # Collect branches to use for git log
      branches = branch ? ["", ""] : collect_branches(pipe)

      # Create pipe for the git log to acquire commits
      pipe = Pipe.new("git --no-pager log #{branches.join(' ')} --date=iso --reverse"\
                      " --no-color --find-copies-harder --numstat --encoding=utf-8"\
                      " --summary #{time_since} #{time_until}"\
                      " --format=\"%H,%an,%ae,%ad,%p\"")

      # Use a buffer approach to queue up lines from the log for each commit
      buffer = []
      pipe.each do |line|

        # Extract the buffer (commit) when we match ','x5 in the log format (delimeter)
        if line.split(',').size == 5

          # Sometimes 'git log' doesn't populate the buffer (i.e., merges), try fallback option if so
          buffer = fall_back_collect_commit(buffer[0].split(',').first) if buffer.one?

          extract_commit(buffer) unless buffer.empty?
          buffer = []

          # Save commits to file if size exceeds limit or forced
          @commits.flush_commits
          @repo = Utilities.get_repository
        end

        buffer << line
      end

      # Extract the last commit
      extract_commit(buffer) unless buffer.empty?
      @commits.flush_commits(true)
    end

    def fall_back_collect_commit(sha)
      # Create pipe for the git log to acquire commits
      pipe = Pipe.new("git --no-pager show #{sha} --date=iso --reverse"\
                      " --no-color --find-copies-harder --numstat --encoding=utf-8 "\
                      "--summary --format=\"%H,%an,%ae,%ad,%p\"")

      # Check that the buffer has valid information (i.e., sha was valid)
      if !pipe.empty? && pipe.first.split(',').first == sha
        pipe.to_a
      else
        []
      end
    end

    def collect_branches(pipe)
      # Acquire all available branches from repository
      branches = []
      pipe.each do |line|
        # Remove the '*' leading the current branch
        line = line[1..-1] if line[0] == '*'
        branches << line.clean_for_authors
      end

      return branches
    end

    def acquire_commit_data(line)
      # Split up formated line
      commit_info = line.split(',')

      # Initialize commit data
      data = (@commits[commit_info[0]] ||= Hash.new(0))
      data[:author] = commit_info[1]
      data[:author_email] = commit_info[2]
      data[:time] = commit_info[3]
      data[:files] = []

      # Flag commit as merge if necessary (determined if two parents)
      if commit_info[4].nil? || commit_info[4].split(' ').one?
        data[:merge] = false
      else
        data[:merge] = true
      end

      return {:sha => commit_info[0], :data => data}
    end

    def extract_commit(buffer)
      # Acquire general commit information
      commit_data = acquire_commit_data(buffer[0])

      puts "Extracting #{commit_data[:sha]}" if @verbose

      # Abort if the commit sha extracted form the buffer is invalid
      if commit_data[:sha].scan(/[\d|a-f]{40}/)[0].nil?
        puts "Invalid buffer containing commit information"
        return
      end

      # Identify all changed files for this commit
      files = identify_changed_files(buffer[2..-1])

      # No files were changed in this commit, abort commit
      if files.nil?
        puts "No files were changed"
        return
      end

      # Acquire blob for each changed file and process it
      files.each do |file|
        blob = get_blob(commit_data[:sha], file)

        # Only process blobs, or log the submodules and problematic files
        if blob.instance_of?(Grit::Blob)
          process_blob(commit_data[:data], blob, file)
        elsif blob.instance_of?(Grit::Submodule)
          puts "Ignoring submodule #{blob.name}"
        else
          puts "Problem processing file #{file[:file]}"
        end
      end
      return commit_data[:data]
    end

    def get_blob(sha, file)
      # Split up file for Grit navigation
      file = file[:file].split(File::Separator)

      # Acquire blob of the file for this specific commit
      blob = Utilities.find_blob_in_tree(@repo.tree(sha), file)

      # If we cannot find blob in current commit (deleted file), check previous commit
      if blob.nil? || blob.instance_of?(Grit::Tree)
        prev_commit = @repo.commits(sha).first.parents[0]
        return nil if prev_commit.nil?

        prev_tree = @repo.tree(prev_commit.id)
        blob = Utilities.find_blob_in_tree(prev_tree, file)
      end
      return blob
    end

    def identify_changed_files(buffer)
      return buffer if buffer.nil?

      # For each modification extract the details
      changed_files = []
      buffer.each do |line|
        extracted_line = CommitLineExtractor.new(line)

        # Extract changed file information if it exists
        changed_file_information = extracted_line.changed
        if changed_file_information.any?
          changed_files << changed_file_information
          next  # This line is processed, skip to next
        end

        # Extract details of create/delete files if it exists
        created_or_deleted = extracted_line.created_or_deleted
        if created_or_deleted.any?
          augmented = false
          # Augment changed file with create/delete information if possible
          changed_files.each do |file|
            if file[:file] == created_or_deleted[:file]
              file[:status] = created_or_deleted[:status]
              augmented = true
              break
            end
          end
          changed_files << created_or_deleted unless augmented
          next  # This line is processed, skip to next
        end

        # Extract details of rename/copy files if it exists
        renamed_or_copied = extracted_line.renamed_or_copied
        if renamed_or_copied.any?
          augmented = false
          # Augment changed file with rename/copy information if possible
          changed_files.each do |file|
            if file[:file] == renamed_or_copied[:new_file]
              file[:status] = renamed_or_copied[:status]
              file[:old_file] = renamed_or_copied[:old_file]
              file[:similar] = renamed_or_copied[:similar]
              augmented = true
              break
            end
          end
          changed_files << renamed_or_copied unless augmented
          next  # This line is processed, skip to next
        end
      end

      changed_files
    end

    def process_blob(data, blob, file)
      # Initialize a hash to hold information regarding the file
      file_hash = Hash.new(0)
      file_hash[:name] = file[:file]
      file_hash[:additions] = file[:additions]
      file_hash[:deletions] = file[:deletions]
      file_hash[:status] = file[:status]

      # Add file information to commit itself
      data[file[:status].to_sym] += 1 if file[:status] != nil
      data[:additions] += file[:additions]
      data[:deletions] += file[:deletions]

      # Acquire specifics on blob
      file_hash[:binary] = blob.binary?
      file_hash[:image] = blob.image?
      file_hash[:vendored] = blob.vendored?
      file_hash[:generated] = blob.generated?

      # Identify the language of the blob if possible
      file_hash[:language] = blob.language.nil? ? "Unknown" : blob.language.name
      data[:files] << file_hash

      return data
    end

  end
end
