module VCSToolkit
  module Objects

    class Commit < Object

      attr_reader  :message, :tree, :parent, :author, :date
      hash_on      :message, :tree, :parent, :author, :date
      serialize_on :object_id, :object_type, :message, :tree, :parent, :author, :date

      def initialize(message:, tree:, parent:, author:, date:, object_id: nil, **context)
        @message = message
        @tree    = tree
        @parent  = parent
        @author  = author
        @date    = date

        super object_id:   object_id,
              object_type: :commit,
              **context
      end

    end

  end
end