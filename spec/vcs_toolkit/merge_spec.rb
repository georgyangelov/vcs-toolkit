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

    context 'with conflicts' do
      let(:change_conflict_diff) { described_class.three_way(%w(a b c d), %w(a f c d), %w(a e c d)) }

      it 'detects conflicts' do
        expect(change_conflict_diff).to be_any { |change| change.is_a? VCSToolkit::Conflict }
      end
    end
  end
end