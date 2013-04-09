module GitStatistics
  class Repo < ::Grit::Repo

    def initialize(path = Dir.pwd, opts = {})
      @current_path = path.to_s
      super(detected_git_path, opts)
    rescue Grit::NoSuchPathError, Grit::InvalidGitRepositoryError
      Log.error "You must be in a Git repository to run git_statistics."
      exit 1
    end

    def working_dir
      Pathname.new(super)
    end

    def detected_git_path
      ascending_paths.detect { |path| (path + '.git').exist? } || @current_path
    end

    def ascending_paths
      Pathname.new(@current_path).to_enum(:ascend)
    end

  end
end
