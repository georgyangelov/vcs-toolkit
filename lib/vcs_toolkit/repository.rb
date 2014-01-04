module VCSToolkit

  class Repository
    attr_reader :repository, :working_dir, :staging_area,
                :commit_class, :tree_class, :blob_class, :label_class

    attr_accessor :head

    def initialize(repository, working_dir, staging_area: working_dir,
                                            head:         nil,
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

      self.head = head if head
    end

    def head=(commit_or_label_or_object_id)
      case commit_or_label_or_object_id
      when Objects::Commit
        @head = commit_or_label_or_object_id.object_id
      when Objects::Label
        @head = commit_or_label_or_object_id.reference_id
      when String
        @head = commit_or_label_or_object_id
      when nil
        # Ignore as this will be the start of a new era
      else
        raise UnknownLabelError
      end
    end

    def commit(message, author, date, ignores: [], **context)
      tree = create_tree ignores: ignores, **context

      commit = commit_class.new message: message,
                                tree:    tree.object_id,
                                parent:  head,
                                author:  author,
                                date:    date

      repository.store commit.object_id, commit
      self.head = commit
    end

    protected

    def create_tree(path='', ignores: [], **context)
      files = staging_area.files(path).each_with_object({}) do |file_name, files|
        file_path = concat_path path, file_name

        next if ignored? file_path, ignores or ignored? file_name, ignores

        files[file_name] = blob_class.new content: staging_area.fetch(file_path), **context
      end

      trees = staging_area.directories(path).each_with_object({}) do |dir_name, trees|
        dir_path = concat_path path, dir_name

        next if ignored? dir_path, ignores or ignored? dir_name, ignores

        trees[dir_name] = create_tree dir_path, **context
      end

      files.each do |name, file|
        repository.store file.object_id, file unless repository.key? file.object_id

        files[name] = file.object_id
      end
      trees.each do |name, tree|
        trees[name] = tree.object_id
      end

      tree = tree_class.new files: files,
                            trees: trees,
                            **context

      repository.store tree.object_id, tree unless repository.key? tree.object_id

      tree
    end

    private

    def ignored?(path, ignores)
      ignores.any? do |ignore|
        if ignore.is_a? Regexp
          ignore =~ path
        else
          ignore == path
        end
      end
    end

    def concat_path(directory, file)
      return file if directory.empty?

      file      = file.sub(/^\/+/, '')
      directory = directory.sub(/\/+$/, '')

      "#{directory}/#{file}"
    end
  end

end