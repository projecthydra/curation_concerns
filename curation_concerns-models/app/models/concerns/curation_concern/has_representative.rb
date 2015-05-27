module CurationConcern::HasRepresentative
  extend ActiveSupport::Concern

  included do
    property :representative, predicate: RDF::URI.new('http://opaquenamespace.org/ns/hydra/representative'), multiple: false
  end

  def to_solr(solr_doc={})
    super.tap do |solr_doc|
      solr_doc[Solrizer.solr_name('representative', :stored_searchable)] = representative
    end
  end

end
