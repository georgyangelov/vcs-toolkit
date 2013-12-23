module VCSToolkit
  module Objects

    class Object
      attr_reader :object_id

      def initialize(object_id, named: false)
        @object_id = object_id
        @named = named
      end

      def named?
        @named
      end
    end

    module HashableObject

      protected

      def generate_id
        raise NotImplementedError
      end

      def id_valid?
        @object_id == generate_id
      end
    end

  end
end