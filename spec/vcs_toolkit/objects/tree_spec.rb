require 'spec_helper'

describe VCSToolkit::Objects::Tree do

  let(:files)     { {'README.md' => '1234', 'Rakefile' => '2345'} }
  let(:trees)     { {'lib' => '3456', 'spec' => '4567'}           }

  let(:tree) { described_class.new files, trees }

  context 'interface' do
    it 'has files getter' do
      expect(tree.files).to eq files
    end

    it 'has trees getter' do
      expect(tree.trees).to eq trees
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
      other_tree = described_class.new files, trees

      expect(other_tree.object_id).to eq tree.object_id
    end
  end

  context 'with valid explicit object_id' do
    subject { described_class.new files, trees, object_id: tree.object_id }

    it 'does not raise an error' do
      expect { subject }.to_not raise_error
    end
  end

  context 'with invalid explicit object_id' do
    subject { described_class.new files, trees, object_id: '1234' }

    it 'raises an InvalidObjectError' do
      expect { subject }.to raise_error(VCSToolkit::InvalidObjectError)
    end
  end

end