require 'vcs_toolkit/serializable'

module VCSToolkit
  module Objects

    class Object
      extend Serializable

      attr_reader  :object_id
      serialize_on :object_id

      def initialize(object_id:, named: false, **context)
        @object_id = object_id
        @named = named
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

    module HashableObject

      private

      def generate_id
        raise NotImplementedError
      end

      def id_valid?
        @object_id == generate_id
      end
    end

  end
end