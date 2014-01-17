require 'spec_helper'

describe VCSToolkit::Utils::MemoryFileStore do

  let(:files) do
    {
      'README.md'                             => 'This is a readme file',
      'lib/vcs_toolkit.rb'                    => 'require ...',
      'lib/vcs_toolkit/utils/memory_store.rb' => 'class MemoryStore',
      'lib/vcs_toolkit/utils/object_store.rb' => 'class ObjectStore',
      'lib/vcs_toolkit/objects/object.rb'     => 'class Object',
    }
  end

  subject(:store) { described_class.new files }

  it 'can fetch a file in root' do
    expect(store.fetch('README.md')).to eq files['README.md']
  end

  it 'can fetch a file in another dir' do
    expect(store.fetch('lib/vcs_toolkit.rb')).to eq files['lib/vcs_toolkit.rb']
    expect(store.fetch('lib/vcs_toolkit/utils/memory_store.rb')).to eq 'class MemoryStore'
  end

  it 'can store a file' do
    store.store 'bin/svc', 'simple version control'
    expect(store.fetch('bin/svc')).to eq 'simple version control'
  end

  describe '#file?' do
    it 'returns trueish value for a file' do
      expect(store.file?('README.md')).to be_true
      expect(store.file?('lib/vcs_toolkit.rb')).to be_true
      expect(store.file?('lib/vcs_toolkit/utils/memory_store.rb')).to be_true
    end

    it 'returns falsey value for a directory' do
      expect(store.file?('lib/')).to be_false
    end

    it 'returns falsey value for non-existent files' do
      expect(store.file?('data/test')).to be_false
      expect(store.file?('lib/vcs_toolkit.rb/')).to be_false
    end
  end

  describe '#directory?' do
    it 'returns trueish value for a directory' do
      expect(store.directory?('lib')).to be_true
      expect(store.directory?('lib/vcs_toolkit')).to be_true
      expect(store.directory?('lib/vcs_toolkit/utils/')).to be_true
    end

    it 'returns falsey value for a file' do
      expect(store.directory?('README.md')).to be_false
      expect(store.directory?('lib/vcs_toolkit.rb')).to be_false
    end

    it 'returns falsey value for non-existent directory' do
      expect(store.directory?('data/test')).to be_false
    end
  end

  it 'can iterate over files' do
    expect(store.files.to_a).to match_array [
      'README.md',
    ]
  end

  it 'does not confuse files and directories with the same prefix' do
    expect(store.files('lib/vcs_toolkit').to_a).to be_empty
  end

  it 'can iterate over files in inner directories' do
    expect(store.files('lib/vcs_toolkit/utils/').to_a).to match_array [
      'memory_store.rb',
      'object_store.rb',
    ]
  end

  it 'can iterate over directories' do
    expect(store.directories.to_a).to match_array %w(lib)
  end

  it 'can iterate over directories in inner directories' do
    expect(store.directories('lib/vcs_toolkit').to_a).to match_array %w(utils objects)
  end

  describe '#changed?' do
    it 'detects changed files' do
      blob = VCSToolkit::Objects::Blob.new content: files['lib/vcs_toolkit/objects/object.rb']
      files['lib/vcs_toolkit/objects/object.rb'] = 'changed content'

      expect(store.changed? 'lib/vcs_toolkit/objects/object.rb', blob).to be_true
    end

    it 'detects non-changed files' do
      files.each do |name, content|
        blob = VCSToolkit::Objects::Blob.new content: content

        expect(store.changed? name, blob).to be_false
      end
    end
  end

  describe '#delete_file' do
    it 'deletes files' do
      store.delete_file 'lib/vcs_toolkit/utils/memory_store.rb'

      expect(store.file? 'lib/vcs_toolkit/utils/memory_store.rb').to be_false
    end
  end

end