IdeesBebe::Application.routes.draw do

  root 'welcome#index'
  get '/forbidden' => 'welcome#forbidden', as: 'forbidden'

  namespace :admin do
    resources :dashboard, only: :index
    resources :products, only: :index
  end
  

  resources :profiles, except: [:index, :create, :new] do
    resources :products, shallow: true
    resources :messages, only: :index
  end

  resources :products, only: [] do
    resources :photos, only: [:destroy, :update, :create], shallow: true
    resources :status, only: [:index, :show, :update]
    resources :messages, only: :create
    resources :reports, only: :create
  end

  resources :categories, only: [:show] do
    get '/:id', action: :show_subcategory, as: 'subcategory'
  end

  resources :inbox, only: [:show, :create]

  devise_scope :user do
    get '/admin', to: 'admin/sessions#new'
    post '/admin', to: 'admin/sessions#create'
  end
  devise_for :user, controllers: { omniauth_callbacks: 'omniauth_callbacks' }
end
