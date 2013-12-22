require 'spec_helper'

describe VCSToolkit::Conflict do
  let(:diff_one) { VCSToolkit::Diff.from_sequences(%w(a b c), %w(a d c)) }
  let(:diff_two) { VCSToolkit::Diff.from_sequences(%w(a b c), %w(a e c)) }

  let(:conflict) { VCSToolkit::Conflict.new diff_one, diff_two }

  describe '#diff_one' do
    subject { conflict.diff_one  }
    it      { should eq diff_one }
  end

  describe '#diff_two' do
    subject { conflict.diff_two  }
    it      { should eq diff_two }
  end

  describe '#conflict?' do
    subject { conflict.conflict? }
    it      { should eq true     }
  end

  it 'responds to Diff::LCS::Change predicate methods' do
    expect(conflict.adding?    ).to eq false
    expect(conflict.deleting?  ).to eq false
    expect(conflict.unchanged? ).to eq false
    expect(conflict.changed?   ).to eq false
    expect(conflict.finished_a?).to eq false
    expect(conflict.finished_b?).to eq false
  end
end