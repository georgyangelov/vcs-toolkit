module VCSToolkit
  module Objects

    class Label < Object
      attr_reader :reference_id

      def initialize(name, reference_id, **context)
        @reference_id = reference_id
        super name, named: true, **context
      end

      def ==(other)
        object_id == other.object_id and reference_id == other.reference_id
      end

      alias_method :eql?, :==

      def hash
        [object_id, reference_id].hash
      end
    end

  end
end