module ActionDispatch::Routing
  class Mapper
    def curation_concerns_basic_routes
      resources :downloads, only: :show
      # Batch edit routes
      get 'upload_sets/:id/edit' => 'upload_sets#edit', as: :edit_upload_set
      post 'upload_sets/:id' => 'upload_sets#update', as: :upload_set_file_sets

      CurationConcerns.config.registered_curation_concern_types.map(&:tableize).each do |curation_concern_name|
        namespaced_resources curation_concern_name, except: [:index]
      end
      namespace :curation_concerns, path: :concern do
        resources :permissions, only: [] do
          member do
            get :confirm
            post :copy
          end
        end
        resources :file_sets, only: [:new, :create], path: 'container/:parent_id/file_sets'
        resources :file_sets, only: [:show, :edit, :update, :destroy] do
          member do
            get :versions
            put :rollback
          end
        end
      end
    end

    # Used in conjunction with Hydra::Collections::Engine routes.
    # Adds routes for doing paginated searches within a collection's contents
    # @example in routes.rb:
    #     mount Hydra::Collections::Engine => '/'
    #     curation_concerns_collections
    def curation_concerns_collections
      resources :collections, only: :show do
        member do
          get 'page/:page', action: :index
          get 'facet/:id', action: :facet, as: :dashboard_facet
        end
        collection do
          put '', action: :update
          put :remove_member
        end
      end
    end

    # kmr added :show to make tests pass
    def curation_concerns_embargo_management
      resources :embargoes, only: [:index, :edit, :destroy] do
        collection do
          patch :update
        end
      end
      resources :leases, only: [:index, :edit, :destroy] do
        collection do
          patch :update
        end
      end
    end

    private

      # routing namepace arguments, for using a path other than the default
      ROUTE_OPTIONS = { 'curation_concerns' => { path: :concern } }

      # Namespaces routes appropriately
      # @example route_namespaced_target("curation_concerns/generic_work") is equivalent to
      #   namespace "curation_concerns", path: :concern do
      #     resources "generic_work", except: [:index]
      #   end
      def namespaced_resources(target, opts = {})
        if target.include?('/')
          the_namespace = target[0..target.index('/') - 1]
          new_target = target[target.index('/') + 1..-1]
          namespace the_namespace, ROUTE_OPTIONS.fetch(the_namespace, nil) do
            namespaced_resources(new_target, opts)
          end
        else
          resources target, opts
        end
      end
  end
end
