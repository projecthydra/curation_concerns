require 'spec_helper'

describe CurationConcerns::ThumbnailPathService do
  subject { described_class.call(object) }

  context "with a FileSet" do
    let(:object) { FileSet.new(id: '999', mime_type: mime_type) }
    let(:mime_type) { 'image/jpeg' }
    context "that has a thumbnail" do
      before do
        allow(File).to receive(:exist?).and_return(true)
      end
      it { is_expected.to eq '/downloads/999?file=thumbnail' }
    end

    context "that is an audio" do
      let(:mime_type) { 'audio/x-wav' }
      it { is_expected.to eq '/assets/audio.png' }
    end

    context "that has no thumbnail" do
      it { is_expected.to eq '/assets/default.png' }
    end
  end

  context "with a Work" do
    context "that has a thumbnail" do
      let(:object) { CurationConcerns::GenericWork.new(thumbnail_id: '999') }
      let(:representative) { FileSet.new(id: '777') }
      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(FileSet).to receive(:load_instance_from_solr).with('999').and_return(representative)
      end

      it { is_expected.to eq '/downloads/999?file=thumbnail' }
    end

    context "that doesn't have a representative" do
      let(:object) { FileSet.new }
      it { is_expected.to eq '/assets/default.png' }
    end
  end
end
