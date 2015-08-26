class CurationConcerns::SearchBuilder < Hydra::SearchBuilder
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  include Hydra::Collections::SearchBehaviors

  def only_curation_concerns(solr_parameters)
    solr_parameters[:fq] ||= []
    types_to_include = CurationConcerns.config.registered_curation_concern_types.dup
    types_to_include << 'Collection'
    formatted_type_names = types_to_include.map { |class_name| "\"#{class_name}\"" }.join(' ')

    solr_parameters[:fq] << "#{Solrizer.solr_name('has_model', :symbol)}:(#{formatted_type_names})"
  end

  def only_generic_files(solr_parameters)
    solr_parameters[:fq] << ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: GenericFile.to_class_uri)
  end

  def find_one(solr_parameters)
    solr_parameters[:fq] << "_query_:\"{!raw f=id}#{blacklight_params.fetch(:id)}\""
  end

  # Override Hydra::AccessControlsEnforcement (or Hydra::PolicyAwareAccessControlsEnforcement)
  # Allows admin users to see everything (don't apply any gated_discovery_filters for those users)
  def gated_discovery_filters(permission_types = discovery_permissions, ability = current_ability)
    return [] if ability.current_user.groups.include? 'admin'
    super
  end

  # show only files with edit permissions in lib/hydra/access_controls_enforcement.rb apply_gated_discovery
  def discovery_permissions
    return ['edit'] if blacklight_params[:works] == 'mine'
    super
  end
end
