Scioly::Application.routes.draw do

  get "timeslots/update"

  get "signups/new"
  get "signups/list"

  get "home/index"

  namespace :admin do
    get 'index'
    get 'events', :as => :events
    get 'scores'
    get 'scorespublish', :as => :scorespublish
    get 'scoreslideshow'
    get "school/edit"
    put "school/update"
    get 'scorecenter', :controller => :scorecenter, :action => :index
    get 'scorecenter/events'
    match 'scorecenter/events/:id', :controller => :scorecenter, :action => :scores, :via => :get
    match 'scorecenter/events/:id/placings/:team_id', :controller => :scorecenter, :action => :update_event, :via => [:post, :put]
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  resource :user
  get "user/login", :as => :adminlogin
  post "user/login"
  get "user/logout", :as => :adminlogout
  match 'teams/batchnew' => "teams#batchnew", :via=>[:get]
  match 'teams/batchnew' => "teams#batchcreate", :via=>[:post]
  match 'teams/:id/qualify' => "teams#qualify", :via=>[:get], :as=>"team_qualify"
  get 'team', :controller => :home, :action => :team_home, :as=>"team_home"
  resources :teams

  # Rails and I disagree about "schedules" vs "schedule". 
  # Rails thinks they have all the methods
  #   of resources (they do), but I think that it seems better to view the schedule for an
  #   event at the singular:
  #      example.com/schedule/event_name/
  match 'schedule/autocomplete_event' => "schedules#autocomplete_schedule_event", :as => :autocomplete_event_schedule
  match 'schedule/batchnew' => "schedules#batchnew", :via => [:get]
  match 'schedule/batchnew' => "schedules#batchcreate", :via => [:post]
  match 'schedule/:division' => "schedules#index", :as=>:schedule_division, :constraints => { :division => /[A-Z]/ }
  resources :schedules, :path => "/schedule" do
    get 'scores'
    post 'scores', :action => "savescores"
  end
  resources :timeslots
  match '/schedule/:id/register/' => "signups#new", :as => :newsignup
  match '/schedule/:id/confirm/' => "signups#create", :as => :confirmsignup
  match '/signups/:id/delete/' => "signups#destroy", :as => :destroysignup
  match '/signups' => "signups#list", :as => :signups

  resources :tournaments do
    get 'scores'
    get 'scoreslideshow'
    post 'scoreslideshow'
  end
  post 'tournament/activate' => "tournaments#set_active"

  match '/login' => "teams#login"
  match '/login/:division' => "teams#login", :as => :login
  match '/logout' => "teams#logout"

  resources :info
  #match '/info/' => "info#list", :as => :info
  #match '/info/:name' => "info#show", :as => :info_show
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
