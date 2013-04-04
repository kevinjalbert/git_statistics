module GitStatistics
  class Repo

    class NotInRepository < StandardError; end

    def initialize(current_path = nil)
      @path = current_path || Dir.pwd
    end

    def repo
      @repo ||= Grit::Repo.new(path)
    rescue Grit::NoSuchPathError
      Log.error "You must be within a Git project to run git-statistics."
      exit 1
    end

    def path
      detected_git_path
    end

    private

      def detected_git_path
        ascending_paths.detect { |path| (path + '.git').exist? }
      end

      def ascending_paths
        Pathname.new(@path).to_enum(:ascend)
      end

  end
end
