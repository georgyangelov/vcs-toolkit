require 'spec_helper'

describe VCSToolkit::Diff do

  describe 'instance' do
    subject { described_class.new(%w(a b c d), %w(a b d e)) }

    it { should be_a_kind_of Enumerable  }

    it { should respond_to :each         }
    it { should respond_to :has_changes? }
    it { should respond_to :to_s         }
  end

  let(:diff_with_addition)   { described_class.new(%w(a b c d), %w(a b c d e)) }
  let(:diff_with_removal)    { described_class.new(%w(a b c d), %w(a b d))     }
  let(:diff_with_changes)    { described_class.new(%w(a b c d), %w(a c c d))   }
  let(:diff_without_changes) { described_class.new(%w(a b c d), %w(a b c d))   }

  describe '#has_changes?' do
    context 'with no changes' do
      subject { diff_without_changes.has_changes? }
      it      { should be true }
    end

    context 'with changes' do
      subject { diff_with_changes.has_changes? }
      it('should equal false') { should be false }
    end
  end

  describe 'changes' do
    context 'with no changes' do
      subject { diff_without_changes }

      it { should have_exactly(4).items }

      it 'has no changes' do
        should be_all { |change| change.unchanged? }
      end
    end

    context 'with changes' do
      subject { diff_with_changes }

      it 'has a changed item' do
        should be_any { |change| change.changed? }
      end
    end

    context 'with addition' do
      subject { diff_with_addition }

      it 'has an addition change' do
        should be_any { |change| change.adding? }
      end
    end

    context 'with removal' do
      subject { diff_with_removal }

      it 'has a removal change' do
        should be_any { |change| change.deleting? }
      end
    end
  end

end