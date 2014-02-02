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

  let(:new_tree_files) do
    {
      'README_new.md'                         => '1234',
      'lib/vcs_toolkit.rb'                    => '9678',
      'lib/vcs_toolkit/utils/object_store.rb' => '4567',
      'lib/vcs_toolkit/objects/object1.rb'    => '5678',
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
      '9678' => VCSToolkit::Objects::Blob.new(content: 'content 9'),
    }
  end

  let(:tree) do
    double('VCSToolkit::Objects::Tree').tap do |tree|
      allow(tree).to receive(:all_files) { tree_files }
    end
  end

  let(:new_tree) do
    double('VCSToolkit::Objects::Tree').tap do |tree|
      allow(tree).to receive(:all_files) { new_tree_files }
    end
  end

  describe '.compare_tree_and_store' do
    context 'without ignore' do
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

    context 'with ignore' do
      it 'ignores files and directories' do
        expect(tree).to receive(:all_files).with(object_store, ignore: [/_store\.rb$/])

        status = VCSToolkit::Utils::Status.compare_tree_and_store tree,
                                                                  file_store,
                                                                  object_store,
                                                                  ignore: [/_store\.rb$/]
      end
    end

    context 'with nil tree' do
      subject(:status) do
        VCSToolkit::Utils::Status.compare_tree_and_store nil, file_store, object_store
      end

      it 'detects all files as new' do
        expect(status[:deleted]).to be_empty
        expect(status[:changed]).to be_empty
        expect(status[:created]).to match_array [
          'README_new.md',
          'lib/vcs_toolkit.rb',
          'lib/vcs_toolkit/utils/object_store.rb',
          'lib/vcs_toolkit/objects/object1.rb',
        ]
      end
    end
  end

  describe '.compare_trees' do
    context 'without ignore' do
      subject(:status) do
        VCSToolkit::Utils::Status.compare_trees tree, new_tree, object_store
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

    context 'with ignore' do
      it 'ignores files and directories' do
        expect(tree) .to receive(:all_files).with(object_store, ignore: [/_store\.rb$/])
        expect(new_tree).to receive(:all_files).with(object_store, ignore: [/_store\.rb$/])

        status = VCSToolkit::Utils::Status.compare_trees tree,
                                                         new_tree,
                                                         object_store,
                                                         ignore: [/_store\.rb$/]
      end
    end

    context 'with nil base tree' do
      subject(:status) do
        VCSToolkit::Utils::Status.compare_trees nil, new_tree, object_store
      end

      it 'detects all files as new' do
        expect(status[:deleted]).to be_empty
        expect(status[:changed]).to be_empty
        expect(status[:created]).to match_array [
          'README_new.md',
          'lib/vcs_toolkit.rb',
          'lib/vcs_toolkit/utils/object_store.rb',
          'lib/vcs_toolkit/objects/object1.rb',
        ]
      end
    end

    context 'with nil new tree' do
      subject(:status) do
        VCSToolkit::Utils::Status.compare_trees tree, nil, object_store
      end

      it 'detects all files as deleted' do
        expect(status[:deleted]).to match_array [
          'README.md',
          'lib/vcs_toolkit.rb',
          'lib/vcs_toolkit/utils/memory_store.rb',
          'lib/vcs_toolkit/utils/object_store.rb',
          'lib/vcs_toolkit/objects/object.rb',
        ]
        expect(status[:changed]).to be_empty
        expect(status[:created]).to be_empty
      end
    end
  end

end