require 'spec_helper'

describe VCSToolkit::ObjectStore do

  subject { VCSToolkit::ObjectStore.new }

  it { should respond_to :key?  }
  it { should respond_to :fetch }
  it { should respond_to :store }
  it { should respond_to :each  }

  it { should be_a_kind_of Enumerable }

  it 'raises an error on non-overriden methods' do
    expect { subject.key?(:id)        }.to raise_error(NotImplementedError)
    expect { subject.fetch(:id)       }.to raise_error(NotImplementedError)
    expect { subject.store(:id, :obj) }.to raise_error(NotImplementedError)
    expect { subject.each { }         }.to raise_error(NotImplementedError)
  end

end