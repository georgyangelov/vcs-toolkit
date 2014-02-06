require 'spec_helper'

describe VCSToolkit::Repository do

  let(:object_store) { {} }
  let(:staging_area) { VCSToolkit::Utils::MemoryFileStore.new }

  subject(:repo) do
    VCSToolkit::Repository.new object_store, staging_area
  end

  # Prepare doubles for the tests that need a commit/tree/blob hierarchy
  let(:commit) do
    double(VCSToolkit::Objects::Commit, id: '1234', tree: '2345', object_type: :commit)
  end

  let(:tree) do
    double(VCSToolkit::Objects::Tree, id: '2345', object_type: :tree)
  end

  let(:blob) do
    double(VCSToolkit::Objects::Blob, id: '3456', object_type: :blob)
  end

  before(:each) do
    object_store[commit.id] = commit
    object_store[tree.id]   = tree
    object_store[blob.id]   = blob
  end

  it 'has correct getters' do
    expect(repo.object_store).to be object_store
    expect(repo.staging_area).to be staging_area
  end

  it 'has a staging area that defaults to the working directory' do
    repo = VCSToolkit::Repository.new object_store, staging_area

    expect(repo.staging_area).to be staging_area
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

    it 'has empty parent list of the first commit' do
      commit = repo.commit 'commit message', 'me', Date.new

      expect(commit.parents).to be_empty
    end

    it 'sets the correct parent' do
      old_commit = repo.commit 'commit 1', 'me', Date.new
      new_commit = repo.commit 'commit 2', 'me', Date.new

      expect(new_commit.parents).to match_array [old_commit.id]
    end

    it 'updates the branch head commit' do
      old_commit = repo.commit 'commit 1', 'me', Date.new
      new_commit = repo.commit 'commit 2', 'me', Date.new

      expect(repo.branch_head).to eq new_commit.id
    end

    it 'can accept parent list override parameter' do
      old_commit = repo.commit 'commit 1', 'me', Date.new
      new_commit = repo.commit 'commit 2', 'me', Date.new, parents: ['1234']

      expect(new_commit.parents).to match_array ['1234']
    end

  end

  describe '#create_tree' do

    context 'with empty staging area' do
      subject(:repo) { VCSToolkit::Repository.new(object_store, VCSToolkit::Utils::MemoryFileStore.new) }

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
      let(:staging) do
        VCSToolkit::Utils::MemoryFileStore.new({
          'README.md'                             => 'This is a readme file',
          'lib/vcs_toolkit.rb'                    => 'require ...',
          'lib/vcs_toolkit/utils/memory_store.rb' => 'class MemoryStore',
          'lib/vcs_toolkit/utils/object_store.rb' => 'class ObjectStore',
          'lib/vcs_toolkit/objects/object.rb'     => 'class Object',
        })
      end

      subject(:repo) do
        VCSToolkit::Repository.new object_store, staging
      end

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
    repo.set_label 'test_label', '123456'
    expect(repo['test_label']).to be_a VCSToolkit::Objects::Label
  end

  it 'overrides already set labels' do
    repo.set_label 'test_label', '123456'
    repo.set_label 'test_label', '654321'

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
      expect(repo.status(double(tree: 'tree'))).to eq files
    end

    it 'passes nil as the tree if there are no commits' do
      files = {
        created: %w(f1 f2 f3),
        changed: [],
        deleted: [],
      }

      expect(VCSToolkit::Utils::Status).to receive(:compare_tree_and_store).
        with(nil, staging_area, object_store, ignore: []).
        and_return(files)

      expect(repo.status(nil)).to eq files
    end
  end

  describe '#history' do
    it 'works with no commits' do
      expect(repo.history.to_a).to be_empty
    end

    it 'delegates to Commit#history' do
      commit = repo.commit 'message', 'me', 'date'

      expect(commit).to receive(:history).with(repo.object_store).and_return(:history)
      expect(repo.history).to eq :history
    end
  end

  describe '#file_difference' do
    it 'loads the file contents and passes them to Diff.from_sequences' do
      tree.stub(:all_files) { {'README' => '1', 'lib/vcs' => blob.id, 'spec/lib/vcs' => '1'}.each }
      blob.stub(:content)   { "ad\ncb\n" }

      repo.staging_area.store 'lib/vcs', "ab\ncd\n"

      expect(VCSToolkit::Diff).to receive(:from_sequences).
                                  with(["ad\n", "cb\n"], ["ab\n", "cd\n"]).
                                  and_return(:diff_result)

      expect(repo.file_difference('lib/vcs', commit)).to eq :diff_result
    end

    it 'ensures there is a newline at the end of the files' do
      tree.stub(:all_files) { {'lib/vcs' => blob.id}.each }
      blob.stub(:content)   { "ad\ncb" }

      repo.staging_area.store 'lib/vcs', "ab\ncd"

      expect(VCSToolkit::Diff).to receive(:from_sequences).
                                  with(["ad\n", "cb\n"], ["ab\n", "cd\n"]).
                                  and_return(:diff_result)

      expect(repo.file_difference('lib/vcs', commit)).to eq :diff_result
    end

    it 'considers a file in the working dir to be empty if it cannot be found' do
      tree.stub(:all_files) { {'lib/vcs' => '3456'}.each }
      blob.stub(:content)   { "ad\ncb\n" }

      expect(VCSToolkit::Diff).to receive(:from_sequences).
                                  with(["ad\n", "cb\n"], []).
                                  and_return(:diff_result)

      expect(repo.file_difference('lib/vcs', commit)).to eq :diff_result
    end

    it 'considers a file in the repository to be empty if it cannot be found' do
      tree.stub(:all_files) { {}.each }

      repo.staging_area.store 'lib/vcs', "ab\ncd\n"

      expect(VCSToolkit::Diff).to receive(:from_sequences).
                                  with([], ["ab\n", "cd\n"]).
                                  and_return(:diff_result)

      expect(repo.file_difference('lib/vcs', commit)).to eq :diff_result
    end
  end

  describe '#restore' do
    it 'can restore a deleted file' do
      expect(tree).to receive(:find).with(repo.object_store, 'lib/vcs') { blob.id }
      blob.stub(:content)   { "file content" }

      repo.restore('lib/vcs', commit)

      expect(staging_area.file? 'lib/vcs').to be_true
      expect(staging_area.fetch 'lib/vcs').to eq blob.content
    end

    it 'can restore a changed file' do
      expect(tree).to receive(:find).with(repo.object_store, 'lib/vcs') { blob.id }
      blob.stub(:content)   { "file content" }

      staging_area.store 'lib/vcs', 'modified file content'

      repo.restore('lib/vcs', commit)

      expect(staging_area.fetch 'lib/vcs').to eq blob.content
    end

    it 'can restore directories' do
      staging = VCSToolkit::Utils::MemoryFileStore.new({
        'README.md'                             => 'old README',
        'lib/vcs_toolkit.rb'                    => 'class VCSToolkit',
        'lib/vcs_toolkit/utils/memory_store.rb' => 'class MemoryStore',
        'lib/vcs_toolkit/utils/object_store.rb' => 'class ObjectStore',
        'lib/vcs_toolkit/objects/object.rb'     => 'class Object',
      })

      repo = VCSToolkit::Repository.new object_store, staging
      repo.commit 'test', 'me', Date.new

      staging.store  'README', 'new README'
      staging.store  'lib/vcs_toolkit/objects/object.rb', 'modified Object'
      staging.delete 'lib/vcs_toolkit/utils'

      repo.restore 'lib/vcs_toolkit', repo[repo.branch_head]

      expect(staging.fetch 'README').to eq 'new README'
      expect(staging.fetch 'lib/vcs_toolkit/objects/object.rb').to eq 'class Object'
      expect(staging.fetch 'lib/vcs_toolkit/utils/memory_store.rb').to eq 'class MemoryStore'
      expect(staging.fetch 'lib/vcs_toolkit/utils/object_store.rb').to eq 'class ObjectStore'
    end

    it 'raises an error if the file cannot be found in the commit' do
      expect(tree).to receive(:find).with(repo.object_store, 'lib/vcs') { nil }

      staging_area.store 'lib/vcs', 'new file content'

      expect { repo.restore('lib/vcs', commit) }.to raise_error

      expect(staging_area.file? 'lib/vcs').to be_true
      expect(staging_area.fetch 'lib/vcs').to eq 'new file content'
    end
  end

  describe '#merge' do
    let(:staging_area) do
      VCSToolkit::Utils::MemoryFileStore.new({})
    end

    let(:objects) do
      {
        0 => double(VCSToolkit::Objects::Blob,   id: 0, content: "1\n2\n3\n4"),
        1 => double(VCSToolkit::Objects::Tree,   id: 1),
        2 => double(VCSToolkit::Objects::Tree,   id: 2),
        3 => double(VCSToolkit::Objects::Tree,   id: 3),
        4 => double(VCSToolkit::Objects::Commit, id: 4, tree: 1),
        5 => double(VCSToolkit::Objects::Commit, id: 5, tree: 2),
        6 => double(VCSToolkit::Objects::Commit, id: 6, tree: 3),
        7 => double(VCSToolkit::Objects::Blob,   id: 7, content: "1\n2\n4"),
        8 => double(VCSToolkit::Objects::Blob,   id: 8, content: "1\n2\n3\n8"),
      }
    end

    let(:diff) do
      double(VCSToolkit::Diff)
    end

    subject(:repo) do
      VCSToolkit::Repository.new objects, staging_area
    end

    before(:each) do
      allow(objects[5]).to receive(:common_ancestor).
                           with(objects[6], objects).
                           and_return(objects[4])

      objects[1].stub(:all_files) { {'file1' => 0} }
      objects[2].stub(:all_files) { {'file1' => 7} }
      objects[3].stub(:all_files) { {'file1' => 8} }

      allow(diff).to receive(:new_content).
                     with("<<<< 5\n", ">>>>> 6\n", "=====\n").
                     and_return(["new\n", "file\n", "content"])
    end

    it 'uses VCSToolkit::Merge to merge files' do
      expect(VCSToolkit::Merge).to receive(:three_way).
                                   with(["1\n", "2\n", "3\n", "4"],
                                        ["1\n", "2\n", "4"],
                                        ["1\n", "2\n", "3\n", "8"]).
                                   and_return(diff)

      repo.merge(objects[5], objects[6])
    end

    it 'stores modified files to the staging area' do
      allow(VCSToolkit::Merge).to receive(:three_way).and_return(diff)

      expect(staging_area).to receive(:store).
                              with('file1', "new\nfile\ncontent")

      repo.merge(objects[5], objects[6])
    end

    it 'removes deleted files from the staging area' do
      empty_diff = double(VCSToolkit::Diff)
      empty_diff.stub(:new_content) { [] }

      expect(VCSToolkit::Merge).to receive(:three_way).and_return(empty_diff)
      expect(staging_area).to receive(:delete_file).with('file1')

      repo.merge(objects[5], objects[6])
    end

    it 'treats non-existing ancestor files as empty' do
      objects[0].stub(:content) { '' }

      expect(VCSToolkit::Merge).to receive(:three_way).
                                   with([],
                                        ["1\n", "2\n", "4"],
                                        ["1\n", "2\n", "3\n", "8"]).
                                   and_return(diff)

      repo.merge(objects[5], objects[6])
    end

    it 'treats non-existing commit files as empty' do
      objects[7].stub(:content) { '' }

      expect(VCSToolkit::Merge).to receive(:three_way).
                                   with(["1\n", "2\n", "3\n", "4"],
                                        [],
                                        ["1\n", "2\n", "3\n", "8"]).
                                   and_return(diff)

      repo.merge(objects[5], objects[6])
    end

    it 'works with non-existing ancestor commit by assuming empty files' do
      allow(objects[5]).to receive(:common_ancestor).
                           with(objects[6], objects).
                           and_return(nil)

      expect(VCSToolkit::Merge).to receive(:three_way).
                                   with([],
                                        ["1\n", "2\n", "4"],
                                        ["1\n", "2\n", "3\n", "8"]).
                                   and_return(diff)

      repo.merge(objects[5], objects[6])
    end
  end

end