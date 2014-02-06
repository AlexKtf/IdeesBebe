IdeesBebe::Application.routes.draw do

  root 'welcome#index'
  get '/forbidden' => 'welcome#forbidden', as: 'forbidden'
  
  devise_for :user

  resources :profiles, except: [:index, :create, :new] do
    resources :products, shallow: true
  end

  resources :products, only: [] do
    resources :comments, only: [:create, :destroy], shallow: true
    resources :product_assets, only: [:destroy, :update, :create], shallow: true
    resources :messages, only: [:create, :index, :show]
  end


  get '/categories/:id' => 'products#by_category', as: 'products_by_categories'
  post '/profiles/:profile_id/products' => 'products#create', as: 'products'

  resources :inbox, only: [:show, :create]

  devise_for :user, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  root 'welcome#index'


end
