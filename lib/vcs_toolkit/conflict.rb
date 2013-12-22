require 'vcs_toolkit/diff'

module VCSToolkit
  class Conflict
    attr_reader :diff_one, :diff_two

    def initialize(diff_one, diff_two)
      @diff_one = diff_one
      @diff_two = diff_two
    end
  end
end