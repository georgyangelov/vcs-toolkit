require 'spec_helper'

describe VCSToolkit::FileStore do

  subject { VCSToolkit::FileStore.new }

  it { should respond_to :fetch          }
  it { should respond_to :store          }
  it { should respond_to :file?          }
  it { should respond_to :directory?     }
  it { should respond_to :changed?       }
  it { should respond_to :exist?         }
  it { should respond_to :each_file      }
  it { should respond_to :files          }
  it { should respond_to :each_directory }
  it { should respond_to :directories    }

  it 'raises an error on non-overriden methods' do
    expect { subject.fetch('README.md')       }.to raise_error(NotImplementedError)
    expect { subject.store('README.md', :obj) }.to raise_error(NotImplementedError)
    expect { subject.file?('README.md')       }.to raise_error(NotImplementedError)
    expect { subject.directory?('README.md')  }.to raise_error(NotImplementedError)
    expect { subject.changed?('README', '')   }.to raise_error(NotImplementedError)
    expect { subject.each_file { }            }.to raise_error(NotImplementedError)
    expect { subject.each_directory { }       }.to raise_error(NotImplementedError)
  end

  context 'with each_file and each_directory implementation' do

    let(:custom_file_store) do
      filesystem = {
        '' => {
          files: ['README.md', 'test.txt'],
          dirs:  ['bin', 'lib'],
        },
        'bin' => {
          files: ['scv'],
          dirs:  ['lib'],
        },
        'lib' => {
          files: ['scv.rb'],
          dirs:  [],
        },
        'bin/lib' => {
          files: ['utils.rb'],
          dirs:  [],
        },
      }

      Class.new VCSToolkit::FileStore do
        define_method :each_file do |path='', &block|
          filesystem[path][:files].each &block
        end

        define_method :each_directory do |path='', &block|
          filesystem[path][:dirs].each &block
        end
      end
    end

    subject(:store) { custom_file_store.new }

    describe '#all_files' do
      it 'should enumerate all files' do
        expect(store.all_files.to_a).to match_array [
          'README.md',
          'test.txt',
          'bin/scv',
          'lib/scv.rb',
          'bin/lib/utils.rb',
        ]
      end

      it 'can ignore files' do
        expect(store.all_files(ignore: [/^s/, 'utils.rb']).to_a).to match_array [
          'README.md',
          'test.txt',
        ]
      end

      it 'can ignore directories' do
        expect(store.all_files(ignore: [/^bin/]).to_a).to match_array [
          'README.md',
          'test.txt',
          'lib/scv.rb',
        ]
      end
    end

    describe '#files' do
      it 'enumerates files in the root directory' do
        expect(store.files.to_a).to match_array [
          'README.md',
          'test.txt',
        ]
      end

      it 'enumerates files in sub-directories' do
        expect(store.files('bin').to_a).to match_array [
          'scv',
        ]
      end

      it 'can ignore files' do
        expect(store.files('bin/lib', ignore: ['utils.rb']).to_a).to match_array []
      end
    end

    describe '#directories' do
      it 'enumerates directories in the root directory' do
        expect(store.directories.to_a).to match_array [
          'bin',
          'lib',
        ]
      end

      it 'enumerates directories in sub-directories' do
        expect(store.directories('bin').to_a).to match_array [
          'lib',
        ]
      end

      it 'can ignore directories' do
        expect(store.directories(ignore: ['lib'])).to match_array [
          'bin',
        ]
      end
    end

  end

end