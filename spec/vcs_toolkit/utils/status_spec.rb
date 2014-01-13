require 'spec_helper'

describe VCSToolkit::Utils::Status do

  let(:tree_files) do
    {
      'README.md'                             => '1234',
      'lib/vcs_toolkit.rb'                    => '2345',
      'lib/vcs_toolkit/utils/memory_store.rb' => '3456',
      'lib/vcs_toolkit/utils/object_store.rb' => '4567',
      'lib/vcs_toolkit/objects/object.rb'     => '5678',
    }
  end

  let(:file_store) do
    VCSToolkit::Utils::MemoryFileStore.new({
      'README_new.md'                         => 'content 1',
      'lib/vcs_toolkit.rb'                    => 'content 9',
      'lib/vcs_toolkit/utils/object_store.rb' => 'content 4',
      'lib/vcs_toolkit/objects/object1.rb'    => 'content 5',
    })
  end

  let(:object_store) do
    {
      '1234' => VCSToolkit::Objects::Blob.new(content: 'content 1'),
      '2345' => VCSToolkit::Objects::Blob.new(content: 'content 2'),
      '3456' => VCSToolkit::Objects::Blob.new(content: 'content 3'),
      '4567' => VCSToolkit::Objects::Blob.new(content: 'content 4'),
      '5678' => VCSToolkit::Objects::Blob.new(content: 'content 5'),
    }
  end

  let(:tree) do
    double('VCSToolkit::Objects::Tree').tap do |tree|
      allow(tree).to receive(:all_files) { tree_files }
    end
  end

  describe '.compare_tree_and_store' do
    subject(:status) do
      VCSToolkit::Utils::Status.compare_tree_and_store tree, file_store, object_store
    end

    it 'detects created files' do
      expect(status[:created]).to match_array [
        'README_new.md',
        'lib/vcs_toolkit/objects/object1.rb',
      ]
    end

    it 'detects deleted files' do
      expect(status[:deleted]).to match_array [
        'README.md',
        'lib/vcs_toolkit/objects/object.rb',
        'lib/vcs_toolkit/utils/memory_store.rb',
      ]
    end

    it 'detects changed files' do
      expect(status[:changed]).to match_array [
        'lib/vcs_toolkit.rb',
      ]
    end
  end

end