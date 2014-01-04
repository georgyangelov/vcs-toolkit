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

  subject { described_class.new files }

  it 'can fetch a file in root' do
    expect(subject.fetch('README.md')).to eq files['README.md']
  end

  it 'can fetch a file in another dir' do
    expect(subject.fetch('lib/vcs_toolkit.rb')).to eq files['lib/vcs_toolkit.rb']
    expect(subject.fetch('lib/vcs_toolkit/utils/memory_store.rb')).to eq 'class MemoryStore'
  end

  it 'can store a file' do
    subject.store 'bin/svc', 'simple version control'
    expect(subject.fetch('bin/svc')).to eq 'simple version control'
  end

  describe '#file?' do
    it 'returns trueish value for a file' do
      expect(subject.file?('README.md')).to be_true
      expect(subject.file?('lib/vcs_toolkit.rb')).to be_true
      expect(subject.file?('lib/vcs_toolkit/utils/memory_store.rb')).to be_true
    end

    it 'returns falsey value for a directory' do
      expect(subject.file?('lib/')).to be_false
    end

    it 'returns falsey value for non-existent files' do
      expect(subject.file?('data/test')).to be_false
      expect(subject.file?('lib/vcs_toolkit.rb/')).to be_false
    end
  end

  describe '#directory?' do
    it 'returns trueish value for a directory' do
      expect(subject.directory?('lib')).to be_true
      expect(subject.directory?('lib/vcs_toolkit')).to be_true
      expect(subject.directory?('lib/vcs_toolkit/utils/')).to be_true
    end

    it 'returns falsey value for a file' do
      expect(subject.directory?('README.md')).to be_false
      expect(subject.directory?('lib/vcs_toolkit.rb')).to be_false
    end

    it 'returns falsey value for non-existent directory' do
      expect(subject.directory?('data/test')).to be_false
    end
  end

  it 'can iterate over files' do
    expect(subject.files.to_a).to match_array [
      'README.md',
    ]
  end

  it 'does not confuse files and directories with the same prefix' do
    expect(subject.files('lib/vcs_toolkit').to_a).to be_empty
  end

  it 'can iterate over files in inner directories' do
    expect(subject.files('lib/vcs_toolkit/utils/').to_a).to match_array [
      'memory_store.rb',
      'object_store.rb',
    ]
  end

  it 'can iterate over directories' do
    expect(subject.directories.to_a).to match_array %w(lib)
  end

  it 'can iterate over directories in inner directories' do
    expect(subject.directories('lib/vcs_toolkit').to_a).to match_array %w(utils objects)
  end

end