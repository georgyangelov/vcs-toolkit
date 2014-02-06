require 'spec_helper'

describe VCSToolkit::Diff do

  describe 'instance' do
    subject { described_class.from_sequences(%w(a b c d), %w(a b d e)) }

    it { should be_a_kind_of Enumerable  }

    it { should respond_to :each         }
    it { should respond_to :has_changes? }
    it { should respond_to :to_s         }
    it { should respond_to :new_content  }
  end

  let(:diff_with_addition)   { described_class.from_sequences(%w(a b c d), %w(a b c d e)) }
  let(:diff_with_removal)    { described_class.from_sequences(%w(a b c d), %w(a b d))     }
  let(:diff_with_changes)    { described_class.from_sequences(%w(a b c d), %w(a c c d))   }
  let(:diff_without_changes) { described_class.from_sequences(%w(a b c d), %w(a b c d))   }
  let(:diff_with_conflicts)  { described_class.new([double(VCSToolkit::Conflict, conflict?: true)])   }

  describe '#has_changes?' do
    context 'with no changes' do
      subject { diff_without_changes.has_changes? }
      it      { should be_false }
    end

    context 'with changes' do
      subject { diff_with_changes.has_changes? }
      it('should equal true') { should be_true }
    end
  end

  describe '#has_conflicts?' do
    context 'with no conflicts' do
      subject { diff_with_changes.has_conflicts? }
      it      { should be_false }
    end

    context 'with conflicts' do
      subject { diff_with_conflicts.has_conflicts? }
      it('should equal true') { should be_true }
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

  describe '#to_s' do
    context 'with no changes' do
      subject { diff_without_changes.to_s }
      it      { should eq 'abcd' }
    end

    context 'with addition' do
      subject { diff_with_addition.to_s }
      it      { should eq 'abcd+e' }
    end

    context 'with removal' do
      subject { diff_with_removal.to_s }
      it      { should eq 'ab-cd' }
    end

    context 'with changes' do
      subject { diff_with_changes.to_s }
      it      { should eq 'a-b+ccd' }
    end

    it 'should keep newlines intact' do
      file_one = "one\ntwo\nthree\nfour\n".lines
      file_two = "one\ntwo!\nthree :)\nfour\nfive...\n".lines
      diff     = described_class.from_sequences(file_one, file_two).to_s

      expect(diff).to eq "one\n-two\n+two!\n-three\n+three :)\nfour\n+five...\n"
    end
  end

  describe '#new_content' do
    context 'with no changes' do
      subject { diff_without_changes.new_content('|', '!', '|') }
      it      { should eq %w(a b c d) }
    end

    context 'with addition' do
      subject { diff_with_addition.new_content('|', '!', '|') }
      it      { should eq %w(a b c d e) }
    end

    context 'with removal' do
      subject { diff_with_removal.new_content('|', '!', '|') }
      it      { should eq %w(a b d) }
    end

    context 'with changes' do
      subject { diff_with_changes.new_content('|', '!', '|') }
      it      { should eq %w(a c c d) }
    end

    context 'with conflicts' do
      subject { VCSToolkit::Merge.three_way(%w(a b c d), %w(a f c d), %w(a e c d)).new_content }
      it      { should eq %w(a <<< f >>> e === c d) }
    end

    context 'with conflicts format' do
      subject { VCSToolkit::Merge.three_way(%w(a b c d), %w(a f c d), %w(a e c d)).new_content('(', '|', ')') }
      it      { should eq %w(a ( f | e ) c d) }
    end
  end

end