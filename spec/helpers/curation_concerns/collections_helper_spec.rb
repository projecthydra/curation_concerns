require 'spec_helper'

describe CurationConcerns::CollectionsHelper do

  describe "#link_to_select_collection" do
    let(:collection) { double(id: '123') }
    let(:collectible) { double(id: '456', human_readable_type: 'Generic Work', to_param: '456') }
    before do
      assign(:collection, collection)
    end
    subject { helper.link_to_select_collection(collectible) }

    it "has a link that pops up a modal" do
      expect(subject).to have_selector 'a[data-toggle=modal][data-target="#456-modal"]'
      expect(subject).to have_link 'Add to a Collection', href: '#'
    end
  end

  describe "#link_to_remove_from_collection" do
    let(:collection) { double(id: '123') }
    let(:collectible) { double(id: '456') }
    before do
      assign(:collection, collection)
    end
    subject { helper.link_to_remove_from_collection(collectible) }

    it "has a form that routes to remove the collectible" do
      expect(subject).to have_selector 'a[data-method=put]'
      expect(subject).to have_link 'Remove From Collection',
        href: collections.collection_path('123', collection: { members: 'remove'},
                                          batch_document_ids: [ '456' ])
    end
  end

  describe "#collection_options_for_select" do
    before do
      allow(helper).to receive(:current_user).and_return(User.new)
    end
    let!(:collection1) { Collection.create!(id: '123', title: 'One') }
    let!(:collection2) { Collection.create!(id: '456', title: 'Two') }
    let!(:collection3) { Collection.create!(id: '789', title: 'Thre') }
    subject { helper.collection_options_for_select(collection2) }

    it "excludes the passed in collection" do
      expect(subject).to eq "<option value=\"#{collection1.id}\">#{collection1.title}</option>\n<option value=\"#{collection3.id}\">#{collection3.title}</option>"
    end
  end
end
