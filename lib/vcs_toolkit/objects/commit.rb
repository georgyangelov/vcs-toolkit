module VCSToolkit
  module Objects

    class Commit < Object

      attr_reader  :message, :tree, :parent, :author, :date
      hash_on      :message, :tree, :parent, :author, :date
      serialize_on :id, :object_type, :message, :tree, :parent, :author, :date

      def initialize(message:, tree:, parent:, author:, date:, id: nil, **context)
        @message = message
        @tree    = tree
        @parent  = parent
        @author  = author
        @date    = date

        super id:          id,
              object_type: :commit,
              **context
      end

    end

  end
end