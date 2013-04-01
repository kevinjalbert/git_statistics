module GitStatistics
  class Repository

    class NotInRepository < StandardError; end

    def self.find(path = Dir.pwd)
      Thread.current[:repository] ||= begin
        ascender = Pathname.new(path).to_enum(:ascend)
        repo_path = ascender.detect { |path| (path + '.git').exist? }
        raise NotInRepository unless repo_path
        Grit::Repo.new(repo_path.to_s)
      end
    rescue NotInRepository
      Log.error "You must be within a Git project to run git-statistics."
      exit 0
    end

  end
end
