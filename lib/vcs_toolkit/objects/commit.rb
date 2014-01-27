module VCSToolkit
  module Objects

    class Commit < Object

      attr_reader  :message, :tree, :parents, :author, :date
      hash_on      :message, :tree, :parents, :author, :date
      serialize_on :id, :object_type, :message, :tree, :parents, :author, :date

      def initialize(message:, tree:, parents:, author:, date:, id: nil, **context)
        @message = message
        @tree    = tree
        @parents = parents
        @author  = author
        @date    = date

        super id:          id,
              object_type: :commit,
              **context
      end

    end

  end
end