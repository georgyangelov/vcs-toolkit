require 'spec_helper'

describe VCSToolkit::Objects::Blob do

  let(:content)      { 'blob content' }
  let(:content_hash) { '59873e99cef61a60b3826e1cbb9d4b089ae78c2b' }

  context 'without explicit object_id' do
    subject { described_class.new content: content }

    it 'has a generated object_id' do
      should respond_to :object_id
    end

    it 'is not named' do
      expect(subject.named?).to eq false
    end

    it 'has a default object_id of the blob content hash' do
      expect(subject.object_id).to eq content_hash
    end

    it 'has a blob object_type' do
      expect(subject.object_type).to eq :blob
    end
  end

  context 'with valid explicit object_id' do
    subject { described_class.new content: content, object_id: content_hash }

    it 'doesn\'t raise an error' do
      expect { subject }.to_not raise_error
    end
  end

  context 'with invalid explicit object_id' do
    subject { described_class.new content: content, object_id: '1234' }

    it 'raises an InvalidObjectError' do
      expect { subject }.to raise_error(VCSToolkit::InvalidObjectError)
    end
  end

end