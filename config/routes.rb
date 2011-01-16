Scioly::Application.routes.draw do

  get "admin/index"

  get "signups/new"
  get "signups/list"

  get "home/index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  resource :user
  get "user/login", :as => :adminlogin
  resources :teams

  # Rails and I disagree about "schedules" vs "schedule". 
  # Rails thinks they have all the methods
  #   of resources (they do), but I think that it seems better to view the schedule for an
  #   event at the singular:
  #      example.com/schedule/event_name/
  resources :schedules, :path => "/schedule"
  match '/schedule/:id/register/:time' => "signups#new", :as => :newsignup
  match '/schedule/:id/confirm/:time' => "signups#create", :as => :confirmsignup
  match '/schedule/:id/delete/:time' => "signups#destroy", :as => :destroysignup
  match '/signups' => "signups#list", :as => :signups

  resource :tournament

  match '/login' => "teams#login"
  match '/login/:division' => "teams#login", :as => :login
  match '/logout' => "teams#logout"
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "home#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
