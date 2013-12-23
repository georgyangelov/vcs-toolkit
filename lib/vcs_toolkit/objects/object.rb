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

  end
end