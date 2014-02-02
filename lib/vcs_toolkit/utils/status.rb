module VCSToolkit
  module Utils

    class Status
      class << self

        def compare_tree_and_store(tree, file_store, object_store, ignore: [])
          store_file_paths = file_store.all_files(ignore: ignore).to_a

          return {created: store_file_paths, changed: [], deleted: []} if tree.nil?

          tree_files       = Hash[tree.all_files(object_store, ignore: ignore).to_a]
          tree_file_paths  = tree_files.keys

          created_files = store_file_paths - tree_file_paths
          deleted_files = tree_file_paths  - store_file_paths

          changed_files = (tree_file_paths & store_file_paths).select do |file|
            file_store.changed?(file, object_store.fetch(tree_files[file]))
          end

          {created: created_files, changed: changed_files, deleted: deleted_files}
        end

        def compare_trees(base_tree, new_tree, object_store, ignore: [])
          created_files = []
          changed_files = []
          deleted_files = []

          if base_tree.nil? and new_tree.nil?
            # Do nothing... No changed or deleted files.
          elsif new_tree.nil?
            deleted_files = base_tree.all_files(object_store, ignore: ignore).map(&:first)
          elsif base_tree.nil?
            created_files = new_tree.all_files(object_store, ignore: ignore).map(&:first)
          else
            base_files = Hash[base_tree.all_files(object_store, ignore: ignore).to_a]
            new_files  = Hash[new_tree.all_files(object_store, ignore: ignore).to_a]

            base_file_paths = base_files.keys
            new_file_paths  = new_files.keys

            created_files = new_file_paths  - base_file_paths
            deleted_files = base_file_paths - new_file_paths

            changed_files = (base_file_paths & new_file_paths).select do |file|
              # A file has changed if the ID of it's blob is different
              base_files[file] != new_files[file]
            end

          end

          {created: created_files, changed: changed_files, deleted: deleted_files}
        end

      end
    end

  end
end