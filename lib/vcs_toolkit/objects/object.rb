module VCSToolkit
  module Objects

    class Object
      attr_reader :object_id

      def initialize(object_id)
        @object_id = object_id
      end
    end

  end
end