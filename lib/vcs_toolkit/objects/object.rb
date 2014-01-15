require 'vcs_toolkit/serializable'
require 'vcs_toolkit/utils/hashable_object'

module VCSToolkit
  module Objects

    class Object
      extend  Serializable
      include Utils::HashableObject

      attr_reader  :id, :object_type
      serialize_on :id, :object_type

      def initialize(id:               nil,
                     object_type:      :object,
                     named:            false,
                     verify_object_id: true,
                     **context)
        @object_type = object_type.to_sym
        @named       = named

        if id
          @id = id
          raise InvalidObjectError, 'Invalid id' if verify_object_id and not named? and not id_valid?
        else
          raise InvalidObjectError, 'Named objects should always specify an id' if named?
          @id = generate_id
        end
      end

      def named?
        @named
      end

      def ==(other)
        id == other.id
      end

      alias_method :eql?, :==

      def hash
        id.hash
      end
    end

  end
end