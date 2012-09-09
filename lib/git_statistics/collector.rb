module GitStatistics
  class Collector

    attr_accessor :commits, :verbose

    def initialize(verbose)
      @commits = Commits.new
      @verbose = verbose
      @repo = Utilities.get_repository

      # Abort if no git repository is found
      if @repo == nil
        raise ("No git Repository Found")
      end
    end

    def collect(branch, time_since="", time_until="")
      # Create pipe for git log to acquire branches
      pipe = open("|git --no-pager branch --no-color")

      # Collect branches to use for git log
      branches = collect_branches(pipe)
      branches = ["", ""] if branch

      # Create pipe for the git log to acquire commits
      pipe = open("|git --no-pager log #{branches.join(' ')} --date=iso --reverse"\
                  " --no-color --find-copies-harder --numstat --encoding=utf-8 "\
                  "--summary #{time_since} #{time_until} "\
                  "--format=\"%H,%an,%ae,%ad,%p\"")

      # Use a buffer approach to queue up lines from the log for each commit
      buffer = []
      pipe.each do |line|

        line = Utilities.clean_string(line)

        # Extract the buffer (commit) when we match ','x5 in the log format (delimeter)
        if line.split(',').size == 5
          extract_commit(buffer) if not buffer.empty?
          buffer = []
        end

        buffer << line.strip
      end

      # Extract the last commit
      extract_commit(buffer) if not buffer.empty?
    end

    def collect_branches(pipe)
      # Acquire all availble branches from repository
      branches = []
      pipe.each do |line|

        # Remove the '*' leading the current branch
        line = line[1..-1] if line[0] == '*'
        branches << Utilities.clean_string(line)
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

      # Flag commit as merge if nessecary (determined if two parents)
      if commit_info[4] == nil or commit_info[4].split(' ').size == 1
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

      # Identify all changed files for this commit
      files = identify_changed_files(buffer[2..-1])

      # Acquire blob for each changed file and process it
      files.each do |file|
        blob = get_blob(commit_data[:sha], file)

        # Only process blobs, otherwise log problematic file/blob
        if blob.instance_of?(Grit::Blob)
          process_blob(commit_data[:data], blob, file)
        else
          puts "Problem processing file #{file[:file]}"
        end
      end
    end

    def get_blob(sha, file)
      # Split up file for Grit navigation
      file = file[:file].split(File::Separator)

      # Acquire blob of the file for this specific commit
      blob = Utilities.find_blob_in_tree(@repo.tree(sha), file)

      # If we cannot find blob in current commit (deleted file), check previous commit
      if blob == nil || blob.instance_of?(Grit::Tree)
        prev_commit = @repo.commits(sha).first.parents[0]
        return nil if prev_commit == nil

        prev_tree = @repo.tree(prev_commit.id)
        blob = Utilities.find_blob_in_tree(prev_tree, file)
      end
      return blob
    end

    def identify_changed_files(buffer)
      # For each modification extract the details
      changed_files = []
      buffer.each do |line|

        # Extract changed file information if it exists
        data = extract_change_file(line)
        if data != nil
          changed_files << data
          next  # This line is processed, skip to next
        end

        # Extract details of create/delete files if it exists
        data = extract_create_delete_file(line)
        if data != nil
          augmented = false
          # Augment changed file with create/delete information if possible
          changed_files.each do |file|
            if file[:file] == data[:file]
              file[:status] = data[:status]
              augmented = true
              break
            end
          end
          changed_files << data if !augmented
          next  # This line is processed, skip to next
        end

        # Extract details of rename/copy files if it exists
        data = extract_rename_copy_file(line)
        if data != nil
          augmented = false
          # Augment changed file with rename/copy information if possible
          changed_files.each do |file|
            if file[:file] == data[:new_file]
              file[:status] = data[:status]
              file[:old_file] = data[:old_file]
              file[:similar] = data[:similar]
              augmented = true
              break
            end
          end
          changed_files << data if !augmented
          next  # This line is processed, skip to next
        end
      end
      return changed_files
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

      # Handle submodule if present, otherwise acquire specifics on blob
      if blob.instance_of?(Grit::Submodule)
        file_hash[:language] = "Submodule"
      else
        file_hash[:binary] = blob.binary?
        file_hash[:image] = blob.image?
        file_hash[:vendored] = blob.vendored?
        file_hash[:generated] = blob.generated?

        # Identify the language of the blob if possible
        if blob.language == nil
          file_hash[:language] = "Unknown"
        else
          file_hash[:language] = blob.language.name
        end
      end
      data[:files] << file_hash
    end

    def extract_change_file(line)
      # Use regex to detect a rename/copy changed file | 1  2  /path/{test => new}/file.txt
      changes = line.scan(/^([-|\d]+)\s+([-|\d]+)\s+(.+)\s+=>\s+(.+)/)[0]
      if changes != nil and changes.size == 4
        # Split up the file into the old and new file
        split_file = Utilities.split_old_new_file(changes[2], changes[3])
        return {:additions => changes[0].to_i,
                :deletions => changes[1].to_i,
                :file => Utilities.clean_string(split_file[:new_file]),
                :old_file => Utilities.clean_string(split_file[:old_file])}
      end

      # Use regex to detect a changed file | 1  2  /path/test/file.txt
      changes = line.scan(/^([-|\d]+)\s+([-|\d]+)\s+(.+)/)[0]
      if changes != nil and changes.size == 3
        return {:additions => changes[0].to_i,
                :deletions => changes[1].to_i,
                :file => Utilities.clean_string(changes[2])}
      end
      return nil
    end

    def extract_create_delete_file(line)
      # Use regex to detect a create/delete file | create mode 100644 /path/test/file.txt
      changes = line.scan(/^(create|delete) mode \d+ ([^\\\n]*)/)[0]
      if changes != nil and changes.size == 2
        return {:status => Utilities.clean_string(changes[0]),
                :file => Utilities.clean_string(changes[1])}
      end
      return nil
    end

    def extract_rename_copy_file(line)
      # Use regex to detect a rename/copy file | copy /path/{test => new}/file.txt
      changes = line.scan(/^(rename|copy)\s+(.+)\s+=>\s+(.+)\s+\((\d+)/)[0]
      if changes != nil and changes.size == 4
        # Split up the file into the old and new file
        split_file = Utilities.split_old_new_file(changes[1], changes[2])
        return {:status => Utilities.clean_string(changes[0]),
                :old_file => Utilities.clean_string(split_file[:old_file]),
                :new_file => Utilities.clean_string(split_file[:new_file]),
                :similar => changes[3].to_i}
      end
      return nil
    end

    def print_summary(sort_type, email, n=0)
      # Default to a 0 if given a negative number to display
      n = 0 if n < 0

      # Acquire data based on sorty type and top # to show
      data = @commits.author_top_n_type(sort_type, n)
      if data == nil
        raise "Parameter for --sort is not valid"
      end

      # Acquire formatting pattern for output
      author_length = find_longest_author(data)
      language_length = find_longest_language(data)
      pattern = "%-#{author_length}s | %-#{language_length}s | %7s | %9s | %9s | %7s | %7s | %7s | %6s | %6s |"

      # Print query/header information
      print_header(pattern, sort_type, n, author_length, language_length)

      # Print per author information
      data.each do |key,value|
        puts pattern % [key, "", value[:commits], value[:additions],
                        value[:deletions], value[:create], value[:delete],
                        value[:rename], value[:copy], value[:merges]]
        print_language_data(pattern, value)
      end

      # Reprint query/header for repository information
      print_header(pattern, sort_type, n, author_length, language_length)
      data = @commits.totals
      puts pattern % ["Repository Totals", "", data[:commits],
                      data[:additions], data[:deletions], data[:create],
                      data[:delete], data[:rename], data[:copy], data[:merges]]
      print_language_data(pattern, data)
    end

    def print_language_data(pattern, data)
      # Print information of each language for the data
      data[:languages].each do |key,value|
        puts pattern % ["", key, "", value[:additions], value[:deletions],
                        value[:create], value[:delete], value[:rename],
                        value[:copy], value[:merges]]
      end
    end

    def print_header(pattern, sort_type, n, author_length, language_length)
      total_authors = @commits.author_list.length

      # Print summary information of displayed results
      if n > 0 and n < total_authors
        puts "\nTop #{n} authors(#{total_authors}) sorted by #{sort_type.to_s}\n"
      else
        puts "\nAll authors(#{total_authors}) sorted by #{sort_type.to_s}\n"
      end

      # Print column headers
      puts "-"*87 + "-"*author_length + "-"*language_length
      puts pattern % ['Name/Email', 'Language', 'Commits', 'Additions', 'Deletions', 'Creates', 'Deletes', 'Renames', 'Copies', 'Merges']
      puts "-"*87 + "-"*author_length + "-"*language_length
    end

    def find_longest_author(data)
      # Find the longest author name/email (for string formatting)
      total_authors = @commits.author_list.length
      author_length = 17
      data.each do |key,value|
        author_length = key.length if key.length > author_length
      end
      return author_length
    end

    def find_longest_language(data)
      # Find the longest language name (for string formatting)
      total_language = @commits.language_list.length
      language_length = 9
      @commits.language_list.each do |key,value|
        language_length = key.length if key.length > language_length
      end
      return language_length
    end
  end
end
