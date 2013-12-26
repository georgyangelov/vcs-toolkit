require 'digest/sha1'

require 'vcs_toolkit/exceptions'
require 'vcs_toolkit/objects/object'

module VCSToolkit
  module Objects

    ##
    # A blob is a nameless object that contains a snapshot
    # of a file's data. The file name is stored
    # with the reference to this object (in a Tree object).
    #
    # The object_id of the blob is by default its content's hash.
    #
    # The content is not serialized by default (in Blob.to_hash) because
    # one might decide that content should be
    # handled differently (or in different format).
    #
    class Blob < Object
      include HashableObject

      attr_reader  :content
      serialize_on :object_id

      def initialize(content:, object_id: nil, **context)
        @content = content

        if object_id
          super object_id: object_id, **context
          raise InvalidObjectError unless id_valid?
        else
          super object_id: generate_id, **context
        end
      end

      private

      def generate_id
        Digest::SHA1.hexdigest(@content)
      end
    end

  end
end