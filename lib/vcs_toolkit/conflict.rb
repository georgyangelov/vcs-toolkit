require 'diff-lcs'
require 'vcs_toolkit/diff'

# I know monkey patching is evil but
# this is used only for consistency in arrays
# that contain both Diff::LCS::Change and Conflict.
# So we can do this: `changes.any? { |change| change.conflict? }`
# instead of `changes.any? { |change| change.is_a? VCSToolkit::Conflict }`
class Diff::LCS::Change
  def conflict?
    false
  end
end

module VCSToolkit
  class Conflict
    attr_reader :diff_one, :diff_two

    def initialize(diff_one, diff_two)
      @diff_one = diff_one
      @diff_two = diff_two
    end

    def conflict?
      true
    end

    # These methods are used for compatibility with ::Diff::LCS::Change
    # so we can do this: `changes.any? { |change| change.adding? }`
    # instead of `changes.any? { |change| (not change.is_a? VCSToolkit::Conflict) and change.adding? }`
    def adding?
      false
    end

    def deleting?
      false
    end

    def unchanged?
      false
    end

    def changed?
      false
    end

    def finished_a?
      false
    end

    def finished_b?
      false
    end
  end
end