require 'spec_helper'

describe VCSToolkit::Repository do

  let(:object_store) { {} }
  let(:working_dir)  { VCSToolkit::Utils::MemoryFileStore.new }
  let(:staging_area) { VCSToolkit::Utils::MemoryFileStore.new }

  subject(:repo) { VCSToolkit::Repository.new object_store, working_dir, staging_area: staging_area }

  it 'has correct getters' do
    expect(repo.repository).to   be object_store
    expect(repo.working_dir).to  be working_dir
    expect(repo.staging_area).to be staging_area
  end

  it 'has a staging area that defaults to the working directory' do
    repo = VCSToolkit::Repository.new object_store, working_dir

    expect(repo.staging_area).to be working_dir
  end

  it 'has correct defaults for the object classes' do
    expect(repo.tree_class).to   be VCSToolkit::Objects::Tree
    expect(repo.blob_class).to   be VCSToolkit::Objects::Blob
    expect(repo.label_class).to  be VCSToolkit::Objects::Label
    expect(repo.commit_class).to be VCSToolkit::Objects::Commit
  end

  describe '#commit' do

    it 'creates valid commits' do
      now = Date.new
      commit = repo.commit 'commit message', 'me', now

      expect(commit).to be_a VCSToolkit::Objects::Commit

      expect(object_store).to include(commit.object_id)
      expect(object_store).to include(commit.tree)

      expect(commit.message).to eq 'commit message'
      expect(commit.author).to  eq 'me'
      expect(commit.date).to    eq now
    end

    it 'has nil parent of the first commit' do
      commit = repo.commit 'commit message', 'me', Date.new

      expect(commit.parent).to be nil
    end

    it 'sets the correct parent' do
      old_commit = repo.commit 'commit 1', 'me', Date.new
      new_commit = repo.commit 'commit 2', 'me', Date.new

      expect(new_commit.parent).to eq old_commit.object_id
    end

    it 'updates the head commit' do
      old_commit = repo.commit 'commit 1', 'me', Date.new
      new_commit = repo.commit 'commit 2', 'me', Date.new

      expect(repo.head).to eq new_commit.object_id
    end

  end

  describe '#create_tree' do

    context 'with empty staging area' do
      subject(:repo) { VCSToolkit::Repository.new(object_store, working_dir) }

      it 'creates a valid tree' do
        tree = repo.send :create_tree

        expect(tree).to be_a VCSToolkit::Objects::Tree
        expect(tree.files).to eq({})
        expect(tree.trees).to eq({})
      end

      it 'saves the tree to the object store' do
        tree = repo.send :create_tree

        expect(tree).to be_a VCSToolkit::Objects::Tree
        expect(object_store).to include tree.object_id
      end
    end

    context 'with non-empty staging area' do
      let(:nonempty_working_dir) do
        VCSToolkit::Utils::MemoryFileStore.new({
          'README.md'                             => 'This is a readme file',
          'lib/vcs_toolkit.rb'                    => 'require ...',
          'lib/vcs_toolkit/utils/memory_store.rb' => 'class MemoryStore',
          'lib/vcs_toolkit/utils/object_store.rb' => 'class ObjectStore',
          'lib/vcs_toolkit/objects/object.rb'     => 'class Object',
        })
      end
      subject(:repo) { VCSToolkit::Repository.new(object_store, nonempty_working_dir) }

      it 'creates a valid tree' do
        tree = repo.send :create_tree

        expect(tree).to be_a VCSToolkit::Objects::Tree
        expect(tree.files).to have(1).file

        blob = object_store[tree.files['README.md']]
        expect(blob.content).to eq 'This is a readme file'
      end

      it 'can ignore file names' do
        tree = repo.send :create_tree, ignores: ['README.md']

        expect(tree.files).to be_empty
      end

      it 'can ignore path patterns' do
        tree = repo.send :create_tree, 'lib/vcs_toolkit/', ignores: [/vcs_toolkit\/utils/]

        expect(tree.trees['utils']).to be_nil
        expect(tree.trees['objects']).to be
      end

      it 'passes **context to blob and tree initializers' do
        # TODO
      end
    end

  end

end