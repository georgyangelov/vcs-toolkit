require 'spec_helper'

describe VCSToolkit::Objects::Commit do

  let(:tree)    { 'tree_id'           }
  let(:parent)  { 'parent_commit_id'  }
  let(:author)  { 'Chuck Norris'      }
  let(:message) { 'Bring world peace' }

  let(:commit_id) { '7044ef26b9f7e16ad4d6c9160ea427dc28997d76' }

  let(:commit) { described_class.new message, tree, parent, author }

  context 'interface' do
    it 'has message getter' do
      expect(commit.message).to eq message
    end

    it 'has tree getter' do
      expect(commit.tree).to eq tree
    end

    it 'has parent getter' do
      expect(commit.parent).to eq parent
    end

    it 'has author getter' do
      expect(commit.author).to eq author
    end

    it 'is not named' do
      expect(commit.named?).to eq false
    end
  end

  context 'without explicit object_id' do
    it 'has a generated object_id' do
      expect(commit).to respond_to :object_id
    end

    it 'has a default object_id of the commit content hash' do
      expect(commit.object_id).to eq commit_id
    end
  end

  context 'with valid explicit object_id' do
    subject { described_class.new message, tree, parent, author, object_id: commit.object_id }

    it 'does not raise an error' do
      expect { subject }.to_not raise_error
    end
  end

  context 'with invalid explicit object_id' do
    subject { described_class.new message, tree, parent, author, object_id: '1234' }

    it 'raises an InvalidObjectError' do
      expect { subject }.to raise_error(VCSToolkit::InvalidObjectError)
    end
  end

end