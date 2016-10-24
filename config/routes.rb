Rails.application.routes.draw do
  get 'task/new'

  get 'sessions/new'
  root 'task#start'
  get    'start'   => 'task#start'
  get    'getid'   => 'sessions#new'
  post   'getid'   => 'sessions#create'
  get 'dashboard' => 'task#dashboard'
  post 'posttask' => 'task#posttask'
  get 'getnexttask' => 'task#getnexttask'
  get 'finished' => 'task#finished'
  post 'submitchoice' => 'task#submitchoice'
  post 'auto_save_text' => 'task#auto_save_text'
  get 'index' => 'task#index'
  get 'data' => 'task#data'
  get 'data_task_6' => 'task#data_task_6'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
