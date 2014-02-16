module VCSToolkit
  module Utils

    class Sync
      def initialize(local_store, local_label_name, remote_store, remote_label_name)
        @local_store  = local_store
        @local_label  = local_store.fetch local_label_name
        @remote_store = remote_store
        @remote_label = remote_store.fetch remote_label_name
      end

      ##
      # Pushes local history starting at `local_label` to
      # `remote_store` starting at `remote_label`.
      #
      def push
        raise 'Nothing to push' if @local_label.reference_id.nil?

        local_commit  = @local_store.fetch  @local_label.reference_id
        local_history = local_commit.history(@local_store).to_a

        unless @remote_label.reference_id.nil?
          remote_commit = @remote_store.fetch @remote_label.reference_id

          raise NonFastForwardMergeError unless local_history.include? remote_commit

          # Because the remote head is on our side as well, we can actually
          # use this commit as a reference of what is on the other end.
          #
          # This is due to the way the commit ids are generated (the hash of
          # their content *and their parents*).
          #
          # Also every commit that is in the remote history is also in ours.
          remote_history = remote_commit.history(@local_store).to_a
        else
          remote_history = []
        end

        commits_to_push = local_history - remote_history
        commits_to_push.each { |commit| push_commit commit }

        # Now that everything is pushed change the remote label
        @remote_label.reference_id = local_commit.id
        @remote_store.store @remote_label.id, @remote_label
      end

      private

      def push_commit(commit)
        push_tree @local_store.fetch(commit.tree)
        @remote_store.store commit.id, commit
      end

      def push_tree(tree)
        # Push all blobs
        tree.files.each do |_, blob_id|
          blob = @local_store.fetch blob_id
          @remote_store.store blob.id, blob
        end

        # Push all nested trees
        tree.trees.each do |_, tree_id|
          nested_tree = @local_store.fetch tree_id
          push_tree nested_tree
        end

        @remote_store.store tree.id, tree
      end
    end

    class NonFastForwardMergeError < StandardError
      def initialize(message='The local and remote repository have diverged')
        super
      end
    end

  end
end