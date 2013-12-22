module VCSToolkit
  class Diff
    include Enumerable

    def initialize(changes)
      @changes = changes
    end

    def has_changes?
      @changes.all? { |change| change.unchanged? }
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

    def self.from_sequences(sequence_one, sequence_two)
      new ::Diff::LCS.sdiff(sequence_one, sequence_two)
    end
  end
end