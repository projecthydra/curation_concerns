module CurationConcerns
  module EmbargoesControllerBehavior
    extend ActiveSupport::Concern

    included do
      skip_before_action :normalize_identifier, only: :update

      def destroy
        update_files = !curation_concern.under_embargo? # embargo expired
        remove_embargo(curation_concern)
        flash[:notice] = curation_concern.embargo_history.last
        if update_files
          redirect_to confirm_curation_concerns_permission_path(curation_concern)
        else
          redirect_to edit_embargo_path(curation_concern)
        end
      end

      def update
        filter_docs_with_edit_access!
        copy_visibility = params[:embargoes].values.map { |h| h[:copy_visibility] }
        batch.each do |id|
          ActiveFedora::Base.find(id).tap do |curation_concern|
            remove_embargo(curation_concern)
            curation_concern.copy_visibility_to_files if copy_visibility.include?(id)
          end
        end
        redirect_to embargoes_path
      end
    end

    protected

      def _prefixes
        # This allows us to use the unauthorized template in curation_concerns/base
        @_prefixes ||= super + ['curation_concerns/base']
      end

      def remove_embargo(work)
        work.embargo_visibility! # If the embargo has lapsed, update the current visibility.
        work.deactivate_embargo!
        work.save
      end
  end
end
