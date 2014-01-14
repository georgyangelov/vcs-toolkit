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

    # TODO: This should resolve more levels of references
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

      set_label :head, head
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
    ensure
      tree.release_resources   if tree
      commit.release_resources if commit
    end

    ##
    # Return the object with this object_id or nil if it doesn't exist.
    #
    def get_object(object_id)
      repository.fetch object_id if repository.key? object_id
    end

    alias_method :[], :get_object

    ##
    # Return new, changed and deleted files
    # compared to a specific commit and the staging area.
    #
    # The return value is a hash with :created, :changed and :deleted keys.
    #
    def status(commit_id, ignore: [])
      tree   = get_object(get_object(commit_id).tree)

      Utils::Status.compare_tree_and_store tree,
                                           staging_area,
                                           repository,
                                           ignore: ignore
    end

    protected

    def create_tree(path='', ignore: [/^\./], **context)
      files = staging_area.files(path, ignore: ignore).each_with_object({}) do |file_name, files|
        file_path = concat_path path, file_name

        next if ignored? file_path, ignore

        files[file_name] = blob_class.new content: staging_area.fetch(file_path), **context
      end

      trees = staging_area.directories(path, ignore: ignore).each_with_object({}) do |dir_name, trees|
        dir_path = concat_path path, dir_name

        next if ignored? dir_path, ignore

        trees[dir_name] = create_tree dir_path, **context
      end

      files.each do |name, blob|
        repository.store blob.object_id, blob unless repository.key? blob.object_id

        files[name] = blob.object_id
        blob.release_resources
      end
      trees.each do |name, tree|
        trees[name] = tree.object_id
        tree.release_resources
      end

      tree = tree_class.new files: files,
                            trees: trees,
                            **context

      repository.store tree.object_id, tree unless repository.key? tree.object_id

      tree
    end

    ##
    # Creates a label (named object) pointing to `reference_id`
    #
    # If the label already exists it is overriden.
    #
    def set_label(name, reference_id)
      label = label_class.new object_id: name, reference_id: reference_id

      repository.store name, label

      label.release_resources
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