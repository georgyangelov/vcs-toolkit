require 'digest/sha1'

require 'vcs_toolkit/exceptions'
require 'vcs_toolkit/objects/object'

module VCSToolkit
  module Objects

    class Tree < Object
      include HashableObject

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

      private

      def generate_id
        Digest::SHA1.hexdigest [@files.sort, @trees.sort].inspect
      end
    end
  end
end