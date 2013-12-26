require 'spec_helper'

describe VCSToolkit::Objects::Label do

  let(:label_name)   { 'HEAD' }
  let(:reference_id) { '7044ef26b9f7e16ad4d6c9160ea427dc28997d76' }

  let(:label) { described_class.new name: label_name, reference_id: reference_id }

  context 'interface' do
    it 'has reference_id getter' do
      expect(label.reference_id).to eq reference_id
    end

    it 'is named' do
      expect(label.named?).to eq true
    end
  end

  it 'should equal other labels with the same data' do
    label_two = described_class.new name: label_name, reference_id: reference_id

    expect(label).to eq  label_two
    expect(label).to eql label_two

    expect(label.hash).to eq label_two.hash
  end

  it 'should not equal labels with different data' do
    label_two   = described_class.new name: label_name, reference_id: 'other_ref_id'
    label_three = described_class.new name: 'master',   reference_id: reference_id

    expect(label).to_not eq label_two
    expect(label).to_not eq label_three
  end

end