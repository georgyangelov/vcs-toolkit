module VCSToolkit
  module Utils

    class Sync
      def self.sync(*args)
        new(*args).sync
      end

      def initialize(source_store, source_label_name, destination_store, destination_label_name)
        @source_store      = source_store
        @source_label      = source_store.fetch source_label_name
        @destination_store = destination_store
        @destination_label = destination_store.fetch destination_label_name
      end

      ##
      # Syncs source history starting at `source_label` to
      # `destination_store` starting at `destination_label`.
      #
      def sync
        raise 'Nothing to sync' if @source_label.reference_id.nil?

        destination_commit_id = @destination_label.reference_id
        raise DivergedHistoriesError unless destination_commit_id.nil? or @source_store.key? destination_commit_id

        source_commit   = @source_store.fetch @source_label.reference_id
        commits_to_push = source_commit.history_diff(@source_store) do |commit|
          # Do not follow parent references for commits
          # that are already on the remote.
          @destination_store.key? commit.id
        end

        commits_to_push.each do |commit|
          transfer_commit commit
        end

        # Now that every object is transferred change the destination label
        @destination_label.reference_id = source_commit.id
        @destination_store.store @destination_label.id, @destination_label
      end

      private

      def transfer_commit(commit)
        transfer_tree @source_store.fetch(commit.tree)
        @destination_store.store commit.id, commit
      end

      def transfer_tree(tree)
        # Transfer all blobs
        tree.files.each do |_, blob_id|
          blob = @source_store.fetch blob_id
          @destination_store.store blob.id, blob
        end

        # Transfer all nested trees
        tree.trees.each do |_, tree_id|
          nested_tree = @source_store.fetch tree_id
          transfer_tree nested_tree
        end

        @destination_store.store tree.id, tree
      end
    end

    class DivergedHistoriesError < VCSToolkitError
      def initialize(message='The local and remote histories have diverged')
        super
      end
    end

  end
end