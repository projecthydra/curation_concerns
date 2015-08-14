module CurationConcerns
  module GenericFileBehavior
    extend ActiveSupport::Concern
    include Hydra::Works::GenericFileBehavior
    include Hydra::Works::GenericFile::VirusCheck
    include Hydra::WithDepositor
    include CurationConcerns::Serializers
    include CurationConcerns::Noid
    include CurationConcerns::Permissions
    include CurationConcerns::GenericFile::Export
    include CurationConcerns::GenericFile::Characterization
    include CurationConcerns::BasicMetadata
    include CurationConcerns::GenericFile::Content
    include CurationConcerns::GenericFile::FullTextIndexing
    include CurationConcerns::GenericFile::Indexing
    include CurationConcerns::GenericFile::BelongsToWorks
    include Hydra::AccessControls::Embargoable

    included do
      attr_accessor :file

      # make filename single-value (CurationConcerns::GenericFile::Characterization makes it multivalue)
      def filename
        self[:filename].first
      end
    end

    def human_readable_type
      self.class.to_s.demodulize.titleize
    end

    def representative
      to_param
    end

    def to_solr(solr_doc = {})
      super(solr_doc).tap do |doc|
        # Enables Riiif to not have to recalculate this each time.
        doc['height_isi'] = Integer(height.first) if height.present?
        doc['width_isi'] = Integer(width.first) if width.present?
      end
    end
  end
end
