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

  context 'without explicit id' do
    it 'has a generated id' do
      expect(commit).to respond_to :id
    end

    it 'has a default id of the commit content hash' do
      other_commit = described_class.new message: message,
                                         tree:    tree,
                                         parent:  parent,
                                         author:  author,
                                         date:    date

      expect(commit.id).to eq other_commit.id
    end
  end

  context 'with valid explicit id' do
    subject do
      described_class.new message:   message,
                          tree:      tree,
                          parent:    parent,
                          author:    author,
                          date:      date,
                          id:        commit.id
    end

    it 'does not raise an error' do
      expect { subject }.to_not raise_error
    end
  end

  context 'with invalid explicit id' do
    subject do
      described_class.new message:   message,
                          tree:      tree,
                          parent:    parent,
                          author:    author,
                          date:      date,
                          id:        '1234'
    end

    it 'raises an InvalidObjectError' do
      expect { subject }.to raise_error(VCSToolkit::InvalidObjectError)
    end
  end

end