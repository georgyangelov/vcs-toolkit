module VCSToolkit

  class Repository
    attr_reader :repository, :working_dir, :staging_area

    def initialize(repository, working_dir, staging_area: working_dir)
      @repository   = repository
      @working_dir  = working_dir
      @staging_area = staging_area
    end
  end

end