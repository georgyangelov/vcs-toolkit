require 'spec_helper'

describe VCSToolkit::FileStore do

  subject { VCSToolkit::FileStore.new }

  it { should respond_to :fetch          }
  it { should respond_to :store          }
  it { should respond_to :file?          }
  it { should respond_to :directory?     }
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
    expect { subject.each_file { }            }.to raise_error(NotImplementedError)
    expect { subject.each_directory { }       }.to raise_error(NotImplementedError)
  end

end