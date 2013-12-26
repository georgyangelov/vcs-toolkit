module VCSToolkit
  module Serializable
    def serialize_on(*attributes)
      define_method :to_hash do
        attribute_values = attributes.map { |attribute| public_send attribute }

        Hash[attributes.zip(attribute_values)]
      end
    end

    def from_hash(hash, **other_args)
      kwargs = {}

      hash.each do |key, value|
        kwargs[key.to_sym] = value
      end

      kwargs.merge! other_args

      new **kwargs
    end
  end
end