module VCSToolkit
  module Objects

    class Commit < Object
      include HashableObject

      attr_reader  :message, :tree, :parent, :author, :date
      serialize_on :object_id, :object_type, :message, :tree, :parent, :author, :date

      def initialize(message:, tree:, parent:, author:, date:, object_id: nil, **context)
        @message = message
        @tree    = tree
        @parent  = parent
        @author  = author
        @date    = date

        if object_id
          super object_id:   object_id,
                object_type: :commit,
                **context
          raise InvalidObjectError unless id_valid?
        else
          super object_id:   generate_id,
                object_type: :commit,
                **context
        end
      end

      private

      def generate_id
        Digest::SHA1.hexdigest [@message, @tree, @parent, @author, @date].inspect
      end
    end

  end
end