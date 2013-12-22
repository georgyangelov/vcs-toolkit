require 'spec_helper'

describe VCSToolkit::Conflict do
  let(:diff_one) { VCSToolkit::Diff.from_sequences(%w(a b c), %w(a d c)) }
  let(:diff_two) { VCSToolkit::Diff.from_sequences(%w(a b c), %w(a e c)) }

  let(:conflict) { VCSToolkit::Conflict.new diff_one, diff_two }

  describe '#diff_one' do
    subject { conflict.diff_one }
    it      { should eq diff_one }
  end

  describe '#diff_two' do
    subject { conflict.diff_two }
    it      { should eq diff_two }
  end
end