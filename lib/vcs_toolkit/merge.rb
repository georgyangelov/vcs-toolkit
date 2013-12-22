require 'vcs_toolkit/diff'
require 'vcs_toolkit/conflict'

module VCSToolkit
  module Merge
    extend self

    # TODO: No conflict for the exact same changes
    def three_way(sequence_one, sequence_two, sequence_three)
      diff_one = Diff.from_sequences(sequence_one, sequence_two)
      diff_two = Diff.from_sequences(sequence_one, sequence_three)

      combined_changes = combine_diffs diff_one, diff_two
      merge_changes = combined_changes.flat_map do |line_number, (changeset_one, changeset_two)|
        if changeset_one.all?(&:unchanged?)
          changeset_two
        elsif changeset_two.all?(&:unchanged?)
          changeset_one
        else
          Conflict.new Diff.new(changeset_one), Diff.new(changeset_two)
        end
      end

      Diff.new merge_changes
    end

    private

    ##
    # Group changes by their old index.
    #
    # The structure is as follows:
    #
    #   {
    #     <line_number_on_ancestor> => [
    #       [ <change>, ... ], # The changes in the first file
    #       [ <change>, ... ]  # The changes in the second file
    #     ]
    #   }
    def combine_diffs(diff_one, diff_two)
      Hash.new { |hash, key| hash[key] = [[], []] }.tap do |combined_diff|
        diff_one.each do |change|
          combined_diff[change.old_position].first << change
        end

        diff_two.each do |change|
          combined_diff[change.old_position].last << change
        end
      end
    end

  end
end