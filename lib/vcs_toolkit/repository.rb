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

    def commit(message, author, date, **context)
      tree   = create_tree **context
      commit = commit_class.new message, tree, nil, author, date

      repository.store commit.object_id, commit
    end

    protected

    def create_tree(path='', **context)
      files = staging_area.files(path).each_with_object({}) do |file_name, files|
        file_path = concat_path path, file_name
        files[file_name] = blob_class.new staging_area.fetch(file_path), **context
      end

      trees = staging_area.directories(path).each_with_object({}) do |dir_name, trees|
        dir_path = concat_path path, dir_name
        trees[dir_name] = create_tree dir_name, **context
      end

      files.each do |name, file|
        repository.store file.object_id, file unless repository.key? file.object_id

        files[name] = file.object_id
      end
      trees.each do |name, tree|
        trees[name] = tree.object_id
      end

      tree_class.new(files, trees, **context).tap do |tree|
        repository.store tree.object_id, tree unless repository.key? tree.object_id
      end
    end

    private

    def concat_path(directory, file)
      return file if directory.empty?

      file      = file.sub(/^\/+/, '')
      directory = directory.sub(/\/+$/, '')

      "#{directory}/#{file}"
    end
  end

end