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

  resources :categories, only: [:show] do
    get '/:id', action: :show_subcategory, as: 'subcategory'
  end

  post '/profiles/:profile_id/products' => 'products#create', as: 'products'

  resources :inbox, only: [:show, :create]

end
