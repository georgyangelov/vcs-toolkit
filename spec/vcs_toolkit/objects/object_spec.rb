require 'spec_helper'

describe VCSToolkit::Objects::Object do

  context 'with fresh named instance' do
    subject { described_class.new :custom_object_id, named: true }

    it 'has an object_id reader' do
      expect(subject.object_id).to eq :custom_object_id
    end

    it 'has a #named? reader = true' do
      expect(subject.named?).to eq true
    end
  end

  context 'with fresh nameless instance' do
    subject { described_class.new :object_id_hash }

    it 'has an object_id reader' do
      expect(subject.object_id).to eq :object_id_hash
    end

    it 'has a #named? reader = false' do
      expect(subject.named?).to eq false
    end
  end

end