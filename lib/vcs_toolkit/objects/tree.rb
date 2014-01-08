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

        if object_id
          super object_id:   object_id,
                object_type: :tree,
                **context
          raise InvalidObjectError unless id_valid?
        else
          super object_id:   generate_id,
                object_type: :tree,
                **context
        end
      end

      ##
      # Iterates over all [file, blob_id] pairs recursively
      # (including files in child trees).
      #
      def all_files(object_store)
        enum_for :yield_all_files, object_store
      end

      private

      def yield_all_files(object_store, &block)
        files.each &block

        trees.each do |dir_name, tree_id|
          tree = object_store.fetch tree_id

          tree.all_files(object_store).each do |file_name, blob_id|
            yield File.join(dir_name, file_name), blob_id
          end
        end
      end

      def hash_objects
        [@files.sort, @trees.sort]
      end
    end
  end
end