require 'spec_helper'

describe VCSToolkit::Objects::Tree do

  let(:files)     { %w(file_id_1 file_id_2) }
  let(:trees)     { %w(tree_id_1 tree_id_2) }
  let(:tree_hash) { '1755a5da157dab776abbbf034513943b9d7e1916' }

  context 'interface' do
    subject { described_class.new files, trees }

    it 'has files getter' do
      expect(subject.files).to eq files
    end

    it 'has trees getter' do
      expect(subject.trees).to eq trees
    end
  end

  context 'without explicit object_id' do
    subject { described_class.new files, trees }

    it 'has a generated object_id' do
      should respond_to :object_id
    end

    it 'is not named' do
      expect(subject.named?).to eq false
    end

    it 'has a default object_id of the tree content hash' do
      expect(subject.object_id).to eq tree_hash
    end
  end

  context 'with valid explicit object_id' do
    subject { described_class.new files, trees, object_id: tree_hash }

    it 'doesn\'t raise an error' do
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