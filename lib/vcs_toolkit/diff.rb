require 'diff-lcs'

module VCSToolkit
  class Diff
    include Enumerable

    def initialize(changes)
      @changes = changes
    end

    def has_changes?
      not @changes.all?(&:unchanged?)
    end

    def has_conflicts?
      @changes.any?(&:conflict?)
    end

    def each(&block)
      @changes.each &block
    end

    def to_s
      flat_map do |change|
        if change.unchanged?
          [change.new_element]
        elsif change.deleting?
          ["-#{change.old_element}"]
        elsif change.adding?
          ["+#{change.new_element}"]
        elsif change.changed?
          ["-#{change.old_element}", "+#{change.new_element}"]
        else
          raise "Unknown change in the diff #{change.action}"
        end
      end.join ''
    end

    ##
    # Reconstruct the new sequence from the diff
    #
    def new_content(conflict_start='<<<', conflict_switch='>>>', conflict_end='===')
      flat_map do |change|
        if change.conflict?
          version_one = change.diff_one.new_content(conflict_start, conflict_switch, conflict_end)
          version_two = change.diff_two.new_content(conflict_start, conflict_switch, conflict_end)

          [conflict_start] + version_one + [conflict_switch] + version_two + [conflict_end]
        elsif change.deleting?
          []
        else
          [change.new_element]
        end
      end
    end

    def self.from_sequences(sequence_one, sequence_two)
      new ::Diff::LCS.sdiff(sequence_one, sequence_two)
    end
  end
end