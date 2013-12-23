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
    class Blob < Object
      include HashableObject

      attr_reader :content

      def initialize(content, object_id: nil)
        @content = content

        if object_id
          super object_id
          raise InvalidObjectError unless object_id_correct
        else
          super generate_id
        end
      end

      protected

      def generate_id
        Digest::SHA1.hexdigest(@content)
      end
    end

  end
end