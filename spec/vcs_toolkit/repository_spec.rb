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

      expect(object_store).to include(commit.id)
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

      expect(new_commit.parent).to eq old_commit.id
    end

    it 'updates the head commit' do
      old_commit = repo.commit 'commit 1', 'me', Date.new
      new_commit = repo.commit 'commit 2', 'me', Date.new

      expect(repo.head).to eq new_commit.id
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
        expect(object_store).to include tree.id
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
        tree = repo.send :create_tree, ignore: ['README.md']

        expect(tree.files).to eq({})
      end

      it 'can ignore path patterns' do
        tree = repo.send :create_tree, 'lib/vcs_toolkit/', ignore: [/vcs_toolkit\/utils/]

        expect(tree.trees['utils']).to be_nil
        expect(tree.trees['objects']).to be
      end

      it 'passes **context to blob and tree initializers' do
        # TODO
      end
    end

  end

  it 'finds and creates labels' do
    repo.send :set_label, 'test_label', '123456'
    expect(repo['test_label']).to be_a VCSToolkit::Objects::Label
  end

  it 'overrides already set labels' do
    repo.send :set_label, 'test_label', '123456'
    repo.send :set_label, 'test_label', '654321'

    expect(repo['test_label'].reference_id).to eq '654321'
  end

  describe '#status' do
    it 'calls Utils::Status.compare_tree_and_store' do
      files = {
        created: %w(f1 f2 f3),
        changed: %w(f6 f7),
        deleted: %w(f4 f5),
      }

      expect(VCSToolkit::Utils::Status).to receive(:compare_tree_and_store).and_return(files)
      allow(repo).to receive(:get_object) { double(tree: 'tree') }
      expect(repo.status(nil)).to eq files
    end
  end

  describe '#history' do
    it 'enumerates all commits in order' do
      commits = [
        repo.commit('commit 1', 'me', Date.new),
        repo.commit('commit 2', 'me', Date.new),
        repo.commit('commit 3', 'me', Date.new),
      ]

      expect(repo.history.to_a).to match_array commits.reverse
    end

    it 'works with no commits' do
      expect(repo.history.to_a).to be_empty
    end
  end

  describe '#file_difference' do
    let(:commit) do
      double(VCSToolkit::Objects::Commit, id: '1234', tree: '2345')
    end

    let(:tree) do
      double(VCSToolkit::Objects::Tree, id: '2345')
    end

    let(:blob) do
      double(VCSToolkit::Objects::Blob, id: '3456')
    end

    before(:each) do
      repo.instance_variable_set(:@repository, {
        commit.id => commit,
        tree.id   => tree,
        blob.id   => blob,
      })
    end

    it 'loads the file contents and passes them to Diff.from_sequences' do
      tree.stub(:all_files) { {'README' => '1', 'lib/vcs' => '3456', 'spec/lib/vcs' => '1'}.each }
      blob.stub(:content)   { "ad\ncb\n" }

      expect(repo.staging_area).to receive(:file?).with('lib/vcs').and_return(true)
      expect(repo.staging_area).to receive(:fetch).with('lib/vcs').and_return("ab\ncd\n")

      expect(VCSToolkit::Diff).to receive(:from_sequences).
                                  with(["ad\n", "cb\n"], ["ab\n", "cd\n"]).
                                  and_return(:diff_result)

      expect(repo.file_difference('lib/vcs', commit.id)).to eq :diff_result
    end

    it 'ensures there is a newline at the end of the files' do
      tree.stub(:all_files) { {'lib/vcs' => '3456'}.each }
      blob.stub(:content)   { "ad\ncb" }

      expect(repo.staging_area).to receive(:file?).with('lib/vcs').and_return(true)
      expect(repo.staging_area).to receive(:fetch).with('lib/vcs').and_return("ab\ncd")

      expect(VCSToolkit::Diff).to receive(:from_sequences).
                                  with(["ad\n", "cb\n"], ["ab\n", "cd\n"]).
                                  and_return(:diff_result)

      expect(repo.file_difference('lib/vcs', commit.id)).to eq :diff_result
    end

    it 'considers a file in the working dir to be empty if it cannot be found' do
      tree.stub(:all_files) { {'lib/vcs' => '3456'}.each }
      blob.stub(:content)   { "ad\ncb\n" }

      expect(repo.staging_area).to receive(:file?).with('lib/vcs').and_return(false)

      expect(VCSToolkit::Diff).to receive(:from_sequences).
                                  with(["ad\n", "cb\n"], []).
                                  and_return(:diff_result)

      expect(repo.file_difference('lib/vcs', commit.id)).to eq :diff_result
    end

    it 'considers a file in the repository to be empty if it cannot be found' do
      tree.stub(:all_files) { {}.each }

      expect(repo.staging_area).to receive(:file?).with('lib/vcs').and_return(true)
      expect(repo.staging_area).to receive(:fetch).with('lib/vcs').and_return("ab\ncd\n")

      expect(VCSToolkit::Diff).to receive(:from_sequences).
                                  with([], ["ab\n", "cd\n"]).
                                  and_return(:diff_result)

      expect(repo.file_difference('lib/vcs', commit.id)).to eq :diff_result
    end
  end

end