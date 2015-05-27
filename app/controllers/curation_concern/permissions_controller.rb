class CurationConcern::PermissionsController < ApplicationController
  include CurationConcerns::CurationConcernController
  with_themed_layout '1_column'
  self.curation_concern_type = ActiveFedora::Base

  def confirm
  end

  def copy
    Sufia.queue.push(VisibilityCopyWorker.new(curation_concern.id))
    flash_message = 'Updating file permissions. This may take a few minutes. You may want to refresh your browser or return to this record later to see the updated file permissions.'
    redirect_to polymorphic_path([:curation_concern, curation_concern]), notice: flash_message
  end

  def curation_concern
    @curation_concern ||= self.curation_concern_type.find(params[:id], cast: true)
  end

end
