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

  context 'without explicit object_id' do
    it 'has a generated object_id' do
      expect(tree).to respond_to :object_id
    end

    it 'is not named' do
      expect(tree.named?).to eq false
    end

    it 'has a default object_id of the tree content hash' do
      other_tree = described_class.new files: files, trees: trees

      expect(other_tree.object_id).to eq tree.object_id
    end
  end

  context 'with valid explicit object_id' do
    subject { described_class.new files: files, trees: trees, object_id: tree.object_id }

    it 'does not raise an error' do
      expect { subject }.to_not raise_error
    end
  end

  context 'with reordered files and trees' do
    subject { described_class.new files: files_reordered, trees: trees_reordered }

    it 'has the same object_id' do
      expect(subject.object_id).to eq tree.object_id
    end
  end

  context 'with invalid explicit object_id' do
    subject { described_class.new files: files, trees: trees, object_id: '1234' }

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