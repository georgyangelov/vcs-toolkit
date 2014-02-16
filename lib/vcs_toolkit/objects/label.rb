module VCSToolkit
  module Objects

    class Label < Object
      attr_accessor :reference_id
      serialize_on  :id, :object_type, :reference_id

      def initialize(id:, reference_id:, **context)
        @reference_id = reference_id

        super id:          id,
              object_type: :label,
              named:       true,
              **context
      end

      def ==(other)
        id == other.id and reference_id == other.reference_id
      end

      alias_method :eql?, :==

      def hash
        [id, reference_id].hash
      end
    end

  end
end