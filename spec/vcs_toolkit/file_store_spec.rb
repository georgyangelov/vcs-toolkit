require 'spec_helper'

describe VCSToolkit::FileStore do

  subject { VCSToolkit::FileStore.new }

  it { should respond_to :key?  }
  it { should respond_to :fetch }
  it { should respond_to :store }
  it { should respond_to :each  }

  it { should be_a_kind_of Enumerable }

  it 'raises an error on non-overriden methods' do
    expect { subject.key?('README.md')        }.to raise_error(NotImplementedError)
    expect { subject.fetch('README.md')       }.to raise_error(NotImplementedError)
    expect { subject.store('README.md', :obj) }.to raise_error(NotImplementedError)
    expect { subject.each { }                 }.to raise_error(NotImplementedError)
  end

end