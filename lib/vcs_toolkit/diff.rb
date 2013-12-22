module VCSToolkit
  class Diff
    include Enumerable

    def initialize(sequence_one, sequence_two)
      @changes = ::Diff::LCS.sdiff(sequence_one, sequence_two)
    end

    def has_changes?
      @changes.all? { |change| change.unchanged? }
    end

    def each(&block)
      @changes.each &block
    end
  end
end