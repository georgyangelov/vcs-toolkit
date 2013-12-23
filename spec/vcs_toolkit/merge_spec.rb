require 'spec_helper'

describe VCSToolkit::Merge do
  describe '.three_way' do
    context 'without conflicts' do
      let(:simple_diff) { described_class.three_way(%w(a b c d), %w(a f c d), %w(a b c d e)) }

      it 'should return a Diff' do
        expect(simple_diff).to be_a VCSToolkit::Diff
      end

      it 'should be the diff to the merged file' do
        expect(simple_diff.to_s).to eq 'a-b+fcd+e'
      end
    end

    context 'with different conflicting changes' do
      subject { described_class.three_way(%w(a b c d), %w(a f c d), %w(a e c d)) }

      it 'detects conflicts' do
        should be_any { |change| change.is_a? VCSToolkit::Conflict }
      end
    end

    context 'with the same' do
      context 'change' do
        subject { described_class.three_way(%w(a b c d), %w(a b e d), %w(a b e d)) }

        it 'merges without conflicts' do
          should be_none { |change| change.is_a? VCSToolkit::Conflict }
        end
      end

      context 'addition' do
        subject { described_class.three_way(%w(a b c d), %w(a b c d e), %w(a l b c d e)) }

        it 'merges without conflicts' do
          should be_none { |change| change.is_a? VCSToolkit::Conflict }
        end
      end

      context 'deletion' do
        subject { described_class.three_way(%w(a b c d), %w(a l b d), %w(a b d)) }

        it 'merges without conflicts' do
          should be_none { |change| change.is_a? VCSToolkit::Conflict }
        end
      end
    end

    context 'with conflict with common additions' do
      subject { described_class.three_way(%w(a b c d), %w(a m e f b c d), %w(a m f f b c d)) }

      it 'detects the conflict' do
        should be_any { |change| change.conflict? }
      end

      it 'properly extracts the common additions' do
        expect(subject.select { |change| change.adding? }).to have(2).items
      end
    end

    context 'with conflict with a common non-change' do
      subject { described_class.three_way(%w(a b c d), %w(a e b c d), %w(a f b c d)) }

      it 'detects the conflict' do
        should be_any { |change| change.conflict? }
      end

      it 'properly extracts the common non-change' do
        should have(5).items
      end
    end
  end
end