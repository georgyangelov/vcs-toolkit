module VCSToolkit

  class Repository
    attr_reader :repository, :working_dir, :staging_area
    attr_reader :commit_class, :tree_class, :blob_class, :label_class

    def initialize(repository, working_dir, staging_area: working_dir,
                                            commit_class: Objects::Commit,
                                            tree_class:   Objects::Tree,
                                            blob_class:   Objects::Blob,
                                            label_class:  Objects::Label)
      @repository   = repository
      @working_dir  = working_dir
      @staging_area = staging_area

      @commit_class = commit_class
      @tree_class   = tree_class
      @blob_class   = blob_class
      @label_class  = label_class
    end
  end

end