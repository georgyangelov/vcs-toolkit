require 'spec_helper'

describe VCSToolkit::Objects::Commit do

  let(:tree)    { 'tree_id'              }
  let(:parents) { ['parent1', 'parent2'] }
  let(:author)  { 'Chuck Norris'         }
  let(:message) { 'Bring world peace'    }
  let(:date)    { Date.new               }

  let(:commit) do
    described_class.new message: message,
                        tree:    tree,
                        parents: parents,
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

    it 'has parents getter' do
      expect(commit.parents).to match_array parents
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
                                         parents: parents,
                                         author:  author,
                                         date:    date

      expect(commit.id).to eq other_commit.id
    end
  end

  context 'with valid explicit id' do
    subject do
      described_class.new message: message,
                          tree:    tree,
                          parents: parents,
                          author:  author,
                          date:    date,
                          id:      commit.id
    end

    it 'does not raise an error' do
      expect { subject }.to_not raise_error
    end
  end

  context 'with invalid explicit id' do
    subject do
      described_class.new message: message,
                          tree:    tree,
                          parents: parents,
                          author:  author,
                          date:    date,
                          id:      '1234'
    end

    it 'raises an InvalidObjectError' do
      expect { subject }.to raise_error(VCSToolkit::InvalidObjectError)
    end
  end

  context 'with commit history' do
    def create_commit(id: '', message: 'message', tree: 'tree', parents: [], author: '', date: '')
      VCSToolkit::Objects::Commit.new message: message,
                                      tree:    tree,
                                      parents: parents,
                                      author:  author,
                                      date:    date,
                                      id:      id,
                                      verify_object_id: false
    end

    let(:commits) do
      {
        1 => create_commit(id: 1),
        2 => create_commit(id: 2, parents: [1]),
        3 => create_commit(id: 3, parents: [2]),
        4 => create_commit(id: 4, parents: [2]),
        5 => create_commit(id: 5, parents: [4]),
        6 => create_commit(id: 6, parents: [4]),
        7 => create_commit(id: 7, parents: [3]),
        8 => create_commit(id: 8, parents: [3, 5]),
        9 => create_commit(id: 9, parents: []),
      }
    end

    describe '#history' do
      it 'enumerates all commits in order' do
        expect(commits[7].history(commits).to_a).to eq [
          commits[7],
          commits[3],
          commits[2],
          commits[1],
        ]
      end

      it 'enumerates commits with multiple parents' do
        history = commits[8].history(commits)
        expect(history).to match_array [
          commits[8],
          commits[3],
          commits[2],
          commits[1],
          commits[5],
          commits[4],
        ]
        expect(history.first).to eq commits[8]
      end

      it 'yields the commits if a block is given' do
        expect(commits[7].enum_for(:history, commits).to_a).to eq [
          commits[7],
          commits[3],
          commits[2],
          commits[1],
        ]
      end
    end

    describe '#common_ancestor' do
      it 'returns one common ancestor' do
        expect(commits[5].common_ancestor(commits[7], commits)).to eq commits[2]
        expect(commits[8].common_ancestor(commits[7], commits)).to eq commits[3]
      end

      it 'returns nil if there is no common ancestor' do
        expect(commits[9].common_ancestor(commits[8], commits)).to be_nil
      end
    end
  end

end