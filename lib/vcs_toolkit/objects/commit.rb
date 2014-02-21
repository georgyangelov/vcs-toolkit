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

      ##
      # Enumerates all commits in the current commit's history.
      # If a block is given each commit is yielded to it.
      #
      def history(object_store)
        history_diff(object_store) do |commit|
          yield commit if block_given?

          false
        end
      end

      ##
      # Enumerates commits in the current commit's history.
      #
      # Each commit is yielded and if the block result is a trueish
      # value the commit's parents are not enumerated.
      #
      def history_diff(object_store)
        commits      = {id => self}
        commit_queue = [self]

        until commit_queue.empty?
          commit = commit_queue.shift

          if yield commit
            commits.delete commit.id
            next
          end

          commit.parents.each do |parent_id|
            unless commits.key? parent_id
              parent = object_store.fetch parent_id

              commits[parent_id] = parent
              commit_queue << parent
            end
          end
        end

        commits.values
      end

      def common_ancestor(other_commit, object_store)
        my_ancestors = history(object_store).to_set

        other_commit.enum_for(:history, object_store).find do |ancestor|
          my_ancestors.include? ancestor
        end
      end

    end

  end
end