module CurationConcerns
  module CurationConcern

    def self.actor(curation_concern, *args)
      actor_identifier = curation_concern.class.to_s.split('::').last
      klass = "CurationConcern::#{actor_identifier}Actor".constantize
      klass.new(curation_concern, *args)
    end

    def self.attach_file(generic_file, user, file_to_attach)
      Sufia::GenericFile::Actor.new(generic_file, user).create_content(file_to_attach, file_to_attach.original_filename, 'content', file_to_attach.content_type)
    end
  end
end
