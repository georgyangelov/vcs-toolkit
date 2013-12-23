module VCSToolkit
  module Objects

    class Commit < Object
      include HashableObject

      attr_reader :message, :tree, :parent, :author, :date

      def initialize(message, tree, parent, author, date, object_id: nil)
        @message = message
        @tree    = tree
        @parent  = parent
        @author  = author
        @date    = date

        if object_id
          super object_id
          raise InvalidObjectError unless id_valid?
        else
          super generate_id
        end
      end

      protected

      def generate_id
        Digest::SHA1.hexdigest [@message, @tree, @parent, @author, @date].inspect
      end
    end

  end
end