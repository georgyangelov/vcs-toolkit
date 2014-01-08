require 'vcs_toolkit/serializable'
require 'vcs_toolkit/utils/hashable_object'

module VCSToolkit
  module Objects

    class Object
      extend  Serializable
      include Utils::HashableObject

      attr_reader  :object_id, :object_type
      serialize_on :object_id, :object_type

      def initialize(object_id:, object_type: :object, named: false, **context)
        @object_id   = object_id
        @object_type = object_type.to_sym
        @named       = named
      end

      def named?
        @named
      end

      def ==(other)
        object_id == other.object_id
      end

      alias_method :eql?, :==

      def hash
        object_id.hash
      end
    end

  end
end