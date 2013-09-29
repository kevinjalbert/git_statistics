module GitStatistics
  class Collector

    attr_accessor :repo, :commits_path, :commits

    def initialize(repo, limit, fresh, pretty)
      @repo = repo
      @commits_path = repo.workdir + ".git_statistics"
      @commits = Commits.new(@commits_path, fresh, limit, pretty)
    end

    def collect(branch, options = {})
      walker = Rugged::Walker.new(repo)
      master_head = Rugged::Branch.lookup(repo, "master").tip

      walker.push(master_head)
      walker.each_with_index do |commit, count|
        if valid_commit?(commit, options)
          extract_commit(commit, count + 1)
          @commits.flush_commits
        end
      end

      @commits.flush_commits(true)
    end

    def valid_commit?(commit, options)
      if !options[:time_since].nil?
        return false unless commit.author[:time] > DateTime.parse(options[:time_since].to_s).to_time
      end

      if !options[:time_until].nil?
        return false unless commit.author[:time] < DateTime.parse(options[:time_until].to_s).to_time
      end

      return true
    end

    def acquire_commit_meta(commit_summary)
      # Initialize commit data
      data = (@commits[commit_summary.oid] ||= Hash.new(0))

      data[:author] = commit_summary.author[:name]
      data[:author_email] = commit_summary.author[:email]
      data[:time] = commit_summary.author[:time].to_s
      data[:merge] = commit_summary.merge?
      data[:additions] = commit_summary.additions
      data[:deletions] = commit_summary.deletions
      data[:net] = commit_summary.net
      data[:added_files] = commit_summary.added_files
      data[:deleted_files] = commit_summary.deleted_files
      data[:modified_files] = commit_summary.modified_files
      data[:files] = commit_summary.file_stats.map{ |file| file.to_json }

      return data
    end

    def extract_commit(commit, count)
      Log.info "Extracting(#{count}) #{commit.oid}"
      commit_summary = CommitSummary.new(@repo, commit)

      # Acquire meta information about commit
      commit_data = acquire_commit_meta(commit_summary)

      return commit_data
    end

  end
end
