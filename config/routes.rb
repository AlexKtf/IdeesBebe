IdeesBebe::Application.routes.draw do



  get '/forbidden' => 'welcome#forbidden', as: 'forbidden'
  

  resources :profiles, except: [:index, :create, :new] do
    resources :products, shallow: true
  end

  resources :products, only: [] do
    resources :comments, only: [:create, :destroy], shallow: true
    resources :product_assets, only: [:destroy, :update, :create], shallow: true
  end

  resources :messages, only: [:create]

  get '/categories/:id' => 'products#by_category', as: 'products_by_categories'
  post '/profiles/:profile_id/products' => 'products#create', as: 'products'

  resources :inbox, only: [:show, :create]

  devise_for :user
  root 'welcome#index'

  
  # You can have the root of your site routed with "root"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
