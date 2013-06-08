module GitStatistics
  class Collector

    attr_accessor :repo, :commits_path, :commits

    def initialize(repo, limit, fresh, pretty)
      Grit::Git.git_timeout = 0
      Grit::Git.git_max_size = 0

      @repo = repo
      @commits_path = repo.working_dir + ".git_statistics"
      @commits = Commits.new(@commits_path, fresh, limit, pretty)
    end

    def collect(branch, options = {})
      # Collect branches to use for git log
      branches = branch ? [] : @repo.branches.compact.map(&:name)
      Grit::Commit.find_all(@repo, nil, options).each do |commit|
        extract_commit(commit)
        @commits.flush_commits
      end
    end

    def acquire_commit_meta(commit_summary)
      # Initialize commit data
      data = (@commits[commit_summary.sha] ||= Hash.new(0))

      data[:author] = commit_summary.author.name
      data[:author_email] = commit_summary.author.email
      data[:time] = commit_summary.authored_date.to_s
      data[:merge] = commit_summary.merge?
      data[:additions] = commit_summary.additions
      data[:deletions] = commit_summary.deletions
      data[:net] = commit_summary.net
      data[:new_files] = commit_summary.new_files
      data[:removed_files] = commit_summary.removed_files
      data[:files] = commit_summary.files

      return data
    end

    def extract_commit(commit)
      unless commit.nil?
        commit_summary = CommitSummary.new(commit)
        Log.info "Extracting #{commit_summary.sha}"

        # Acquire meta information about commit
        commit_data = acquire_commit_meta(commit_summary)

        return commit_data
      end
    end

  end
end
