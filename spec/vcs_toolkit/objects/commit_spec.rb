require 'spec_helper'

describe VCSToolkit::Objects::Commit do

  let(:tree)    { 'tree_id'           }
  let(:parent)  { 'parent_commit_id'  }
  let(:author)  { 'Chuck Norris'      }
  let(:message) { 'Bring world peace' }
  let(:date)    { Date.new            }

  let(:commit) do
    described_class.new message: message,
                        tree:    tree,
                        parent:  parent,
                        author:  author,
                        date:    date
  end

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

    it 'has date getter' do
      expect(commit.date).to eq date
    end

    it 'is not named' do
      expect(commit.named?).to eq false
    end

    it 'has a commit object_type' do
      expect(commit.object_type).to eq :commit
    end
  end

  context 'without explicit object_id' do
    it 'has a generated object_id' do
      expect(commit).to respond_to :object_id
    end

    it 'has a default object_id of the commit content hash' do
      other_commit = described_class.new message: message,
                                         tree:    tree,
                                         parent:  parent,
                                         author:  author,
                                         date:    date

      expect(commit.object_id).to eq other_commit.object_id
    end
  end

  context 'with valid explicit object_id' do
    subject do
      described_class.new message:   message,
                          tree:      tree,
                          parent:    parent,
                          author:    author,
                          date:      date,
                          object_id: commit.object_id
    end

    it 'does not raise an error' do
      expect { subject }.to_not raise_error
    end
  end

  context 'with invalid explicit object_id' do
    subject do
      described_class.new message:   message,
                          tree:      tree,
                          parent:    parent,
                          author:    author,
                          date:      date,
                          object_id: '1234'
    end

    it 'raises an InvalidObjectError' do
      expect { subject }.to raise_error(VCSToolkit::InvalidObjectError)
    end
  end

end