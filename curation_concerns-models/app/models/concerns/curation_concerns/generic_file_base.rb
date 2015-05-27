module CurationConcerns
  module GenericFileBase
    extend ActiveSupport::Concern
    include Hydra::AccessControls::Embargoable
    include Sufia::ModelMethods
    include Sufia::Noid
    include Sufia::GenericFile::MimeTypes
    include Sufia::GenericFile::Export
    include Sufia::GenericFile::Characterization
    include Sufia::GenericFile::Derivatives
    include Sufia::GenericFile::Metadata
    include Sufia::GenericFile::Content
    include Sufia::GenericFile::Versions
    include Sufia::GenericFile::VirusCheck
    include Sufia::GenericFile::FullTextIndexing
    include Hydra::Collections::Collectible
    include Sufia::GenericFile::Batches
    include Sufia::GenericFile::Indexing
    include Sufia::Permissions::Readable # Only include Sufia::Permissions::Readable, not Sufia::Permissions::Writable

    included do
      belongs_to :batch, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf, class_name: 'ActiveFedora::Base'

      before_destroy :remove_representative_relationship

      attr_accessor :file
      delegate :latest_version, to: :content

      # make filename single-value (Sufia::GenericFile::Characterization makes it multivalue)
      def filename
        if self[:filename].instance_of?(Array)
          self[:filename].first
        else
          self[:filename]
        end
      end
    end

    def human_readable_type
      self.class.to_s.demodulize.titleize
    end

    def representative
      to_param
    end

    def copy_permissions_from(obj)
      self.datastreams['rightsMetadata'].ng_xml = obj.datastreams['rightsMetadata'].ng_xml
    end

    def update_parent_representative_if_empty(obj)
      return unless obj.representative.blank?
      obj.representative = self.id
      obj.save
    end

    def remove_representative_relationship
      return unless ActiveFedora::Base.exists?(batch)
      return unless batch.representative == self.id
      batch.representative = nil
      batch.save
    end

    def to_solr(solr_doc = {})
      super(solr_doc).tap do |solr_doc|
        # Enables Riiif to not have to recalculate this each time.
        solr_doc['height_isi'] = Integer(height.first) if height.present?
        solr_doc['width_isi'] = Integer(width.first) if width.present?
      end
    end
  end
end
