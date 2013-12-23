require 'spec_helper'

describe VCSToolkit::Objects::Object do

  it 'has an object_id reader' do
    object = described_class.new :custom_object_id

    expect(object.object_id).to eq :custom_object_id
  end

end