require 'digest/sha1'

require 'vcs_toolkit/exceptions'
require 'vcs_toolkit/objects/object'

module VCSToolkit
  module Objects

    class Tree < Object

      attr_reader  :files, :trees
      serialize_on :object_id, :object_type, :files, :trees

      def initialize(files:, trees:, object_id: nil, **context)
        @files = files
        @trees = trees

        super object_id:   object_id,
              object_type: :tree,
              **context
      end

      ##
      # Iterates over all [file, blob_id] pairs recursively
      # (including files in child trees).
      #
      def all_files(object_store, ignore: [])
        enum_for :yield_all_files, object_store, ignore: ignore
      end

      private

      def yield_all_files(object_store, ignore: [], &block)
        files.reject { |path| ignored? path, ignore }.each &block

        trees.each do |dir_name, tree_id|
          tree = object_store.fetch tree_id

          tree.all_files(object_store).each do |file, blob_id|
            file_path = File.join(dir_name, file)

            yield file_path, blob_id unless ignored?(file_path, ignore) or ignored?(file.split('/').last, ignore)
          end
        end
      end

      def ignored?(path, ignores)
        ignores.any? do |ignore|
          if ignore.is_a? Regexp
            ignore =~ path
          else
            ignore == path
          end
        end
      end

      def hash_objects
        [@files.sort, @trees.sort]
      end
    end
  end
end