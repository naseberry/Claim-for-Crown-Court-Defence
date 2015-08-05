Rails.application.routes.draw do

  get 'ping'                => 'ping#index'
  get 'vat'                 => "vat_rates#index"

  get '/404', to: 'errors#not_found', as: :error_404
  get '/500', to: 'errors#internal_server_error', as: :error_500

  devise_for :users, controllers: { sessions: 'sessions' }

  authenticated :user, -> (u) { u.persona.is_a?(Advocate) } do
    root to: 'advocates/claims#index', as: :advocates_home
  end

  authenticated :user, -> (u) { u.persona.is_a?(CaseWorker) } do
    root to: 'case_workers/claims#index', as: :case_workers_home
  end

  devise_scope :user do
    unauthenticated :user do
      root 'sessions#new', as: :unauthenticated_root
    end
  end

  mount API::Root => '/'
  mount GrapeSwaggerRails::Engine => '/api/documentation'

  resources :documents do
    get 'download', on: :member
  end

  resources :messages, only: [:create]
  resources :user_message_statuses, only: [:index, :update]

  namespace :advocates do
    root to: 'claims#index'

    resources :claims do
      get 'confirmation', on: :member
      get 'outstanding', on: :collection
      get 'authorised', on: :collection
      patch 'transition_state', on: :member
    end

    namespace :admin do
      root to: 'claims#index'

      resources :advocates
    end
  end

  namespace :case_workers do
    root to: 'claims#index'

    resources :claims, only: [:index, :show, :update]

    namespace :admin do
      root to: 'allocations#new'

      resources :case_workers do
        get 'allocate', on: :member
      end

      resources :allocations, only: [:new, :create] do
        get '/', to: 'allocations#new', on: :collection
      end
    end
  end
end
