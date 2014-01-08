module VCSToolkit
  module Utils

    module HashableObject
      module ClassMethods
        def hash_on(*attributes)
          if attributes.size == 1
            define_method :hash_objects do
              public_send attributes.first
            end
          else
            define_method :hash_objects do
              attributes.map { |attribute| public_send attribute }.to_a.inspect
            end
          end
        end
      end

      module InstanceMethods
        def hash_objects
          raise NotImplementedError
        end

        protected

        def generate_id
          hash_data = hash_objects
          hash_data = hash_data.inspect unless hash_data.is_a? String

          Digest::SHA1.hexdigest(hash_data)
        end

        def id_valid?
          @object_id == generate_id
        end
      end

      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end

  end
end