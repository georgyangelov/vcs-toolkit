require 'spec_helper'

describe VCSToolkit::Objects::Tree do

  let(:files)           { {'README.md' => '1234', 'Rakefile' => '2345'} }
  let(:trees)           { {'lib' => '3456', 'spec' => '4567'}           }

  let(:files_reordered) { {'Rakefile' => '2345', 'README.md' => '1234'} }
  let(:trees_reordered) { {'spec' => '4567', 'lib' => '3456'}           }

  let(:tree) { described_class.new files: files, trees: trees }

  context 'interface' do
    it 'has files getter' do
      expect(tree.files).to eq files
    end

    it 'has trees getter' do
      expect(tree.trees).to eq trees
    end

    it 'has a tree object_type' do
      expect(tree.object_type).to eq :tree
    end
  end

  context 'without explicit id' do
    it 'has a generated id' do
      expect(tree).to respond_to :id
    end

    it 'is not named' do
      expect(tree.named?).to eq false
    end

    it 'has a default id of the tree content hash' do
      other_tree = described_class.new files: files, trees: trees

      expect(other_tree.id).to eq tree.id
    end
  end

  context 'with valid explicit id' do
    subject { described_class.new files: files, trees: trees, id: tree.id }

    it 'does not raise an error' do
      expect { subject }.to_not raise_error
    end
  end

  context 'with reordered files and trees' do
    subject { described_class.new files: files_reordered, trees: trees_reordered }

    it 'has the same id' do
      expect(subject.id).to eq tree.id
    end
  end

  context 'with invalid explicit id' do
    subject { described_class.new files: files, trees: trees, id: '1234' }

    it 'raises an InvalidObjectError' do
      expect { subject }.to raise_error(VCSToolkit::InvalidObjectError)
    end
  end

  describe '#all_files' do
    let(:object_store) do
      {
        '1' => VCSToolkit::Objects::Tree.new(
          files: {
            'README'   => '987',
            'test.txt' => '967',
          },
          trees: {
            'bin' => '2',
          }
        ),
        '2' => VCSToolkit::Objects::Tree.new(
          files: {
            'vcs' => '123'
          },
          trees: {}
        ),
      }
    end

    subject(:root_tree) { object_store.fetch '1' }

    it 'iterates correctly over all files' do
      expect(root_tree.all_files(object_store).to_a).to match_array [
        ['README',   '987'],
        ['test.txt', '967'],
        ['bin/vcs',  '123'],
      ]
    end

    it 'can ignore files' do
      expect(root_tree.all_files(object_store, ignore: ['README', 'vcs']).to_a).to match_array [
        ['test.txt', '967'],
      ]
    end

    it 'can ignore directories' do
      expect(root_tree.all_files(object_store, ignore: [/^bin/]).to_a).to match_array [
        ['README',   '987'],
        ['test.txt', '967'],
      ]
    end
  end

end