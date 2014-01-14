require 'spec_helper'

describe VCSToolkit::Objects::Object do

  context 'with fresh named instance' do
    subject(:object) { described_class.new object_id: :custom_object_id, named: true }

    it 'has an object_id reader' do
      expect(object.object_id).to eq :custom_object_id
    end

    it 'has a #named? reader = true' do
      expect(object.named?).to eq true
    end

    it 'has an object_type reader' do
      expect(object.object_type).to eq :object
    end
  end

  context 'with fresh nameless instance' do
    subject(:object) do
      described_class.new object_id: :object_id_hash,
                          verify_object_id: false
    end

    it 'has an object_id reader' do
      expect(object.object_id).to eq :object_id_hash
    end

    it 'has a #named? reader = false' do
      expect(object.named?).to eq false
    end
  end

  it 'should equal other objects with the same object_id' do
    object_one = described_class.new object_id: :object_id_one,
                                     verify_object_id: false

    object_two = described_class.new object_id: :object_id_one,
                                     verify_object_id: false

    expect(object_one).to eq  object_two
    expect(object_one).to eql object_two
  end

  it 'should not equal objects with different object_id' do
    object_one = described_class.new object_id: :object_id_one,
                                     verify_object_id: false

    object_two = described_class.new object_id: :object_id_two,
                                     verify_object_id: false

    expect(object_one).to_not eq  object_two
    expect(object_one).to_not eql object_two
  end

end