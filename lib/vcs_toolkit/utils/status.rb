module VCSToolkit
  module Utils

    class Status
      class << self

        def compare_tree_and_store(tree, file_store, object_store, ignore: [])
          tree_files       = Hash[tree.all_files(object_store, ignore: ignore).to_a]
          tree_file_paths  = tree_files.keys
          store_file_paths = file_store.all_files(ignore: ignore).to_a

          created_files = store_file_paths - tree_file_paths
          deleted_files = tree_file_paths  - store_file_paths

          changed_files = (tree_file_paths & store_file_paths).select do |file|
            file_store.changed?(file, object_store.fetch(tree_files[file]))
          end

          {created: created_files, changed: changed_files, deleted: deleted_files}
        end

      end
    end

  end
end