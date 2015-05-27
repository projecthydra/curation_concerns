require 'spec_helper'

describe CurationConcerns::GenericFile do
  it "should have depositor" do
    subject.depositor = 'tess@example.com'
  end

  it "should update attributes" do
    subject.attributes = {title:["My new Title"]}
    expect(subject.title).to eq(["My new Title"])
  end

  describe "to_solr" do
    before do
      subject.title = ['One Flew Over the Cuckoo\'s Nest']
      subject.characterization.height = '500'
      subject.characterization.width = '600'
    end
    let(:solr_doc) { subject.to_solr }

    it "has a solr_doc" do
      expect(solr_doc['title_tesim']).to eq ['One Flew Over the Cuckoo\'s Nest']
      expect(solr_doc['title_sim']).to eq ['One Flew Over the Cuckoo\'s Nest']
      expect(solr_doc['height_isi']).to eq 500
      expect(solr_doc['width_isi']).to eq 600
    end
  end

  context "with versions" do
    it "should have versions" do
      expect(subject.versions.count).to eq 0
    end
  end

  describe 'with a parent work' do
    let(:parent_id) { 'id123' }
    let!(:parent) {
      # if ActiveFedora::Base.exists?(parent_id)
      #   ActiveFedora::Base.eradicate(parent_id)
      # end
      GenericWork.new id: parent_id, title: ['asdf']
    }

    subject { CurationConcerns::GenericFile.create(batch: parent) }

    describe '#remove_representative_relationship' do
      let(:some_other_id) { 'something456' }
      before do
        parent.representative = some_other_id
        parent.save!
      end

      context "the parent object doesn't exist" do
        before do
          parent.representative = subject.id
          parent.save!
          @parent_id = parent.id
          parent.destroy
        end

        it "doesn't raise an error" do
          expect(ActiveFedora::Base.exists?(@parent_id)).to eq false
          expect {
            subject.remove_representative_relationship
          }.to_not raise_error
        end
      end

      context 'it is not the representative' do
        it "doesn't update parent work when file is deleted" do
          expect(subject.batch).to eq parent
          expect(parent.representative).to eq some_other_id
          subject.destroy
          expect(parent.representative).to eq some_other_id
        end
      end

      context 'it is the representative' do
        before do
          parent.representative = subject.id
          parent.save!
        end

        it 'updates the parent work when the file is deleted' do
          expect(subject.batch).to eq parent
          expect(parent.representative).to eq subject.id
          subject.destroy
          expect(parent.representative).to be_nil
        end
      end
    end
  end

end
