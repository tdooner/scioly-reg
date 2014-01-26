Scioly::Application.routes.draw do

  get "timeslots/update"

  get "signups/new"
  get "signups/list"

  namespace :admin do
    get 'index'
    get 'events', :as => :events
    get 'scores'
    get 'scorespublish', :as => :scorespublish
    get 'scoreslideshow'
    get "school/edit"
    put "school/update"
  end

  resource :user
  get "user/login", :as => :adminlogin
  post "user/login"
  get "user/logout", :as => :adminlogout
  match 'teams/batchnew' => "teams#batchnew", :via=>[:get]
  match 'teams/batchnew' => "teams#batchcreate", :via=>[:post]
  match 'teams/:id/qualify' => "teams#qualify", :via=>[:get], :as=>"team_qualify"
  get 'team', :controller => :home, :action => :team_home, :as=>"team_home"
  resources :teams

  match '/schools/new' => 'home#newschool', :via => [ :get ], :as => :new_school
  match '/schools/new' => 'home#createschool', :via => [ :post ]

  resources :schedules, :path => "/schedule" do
    get 'scores'
    post 'scores', :action => "savescores"
    get 'batchnew' => "schedules#batchnew"
    post 'batchnew' => "schedules#batchcreate"

    collection do
      get 'all_pdfs'
      get 'autocomplete_event' => "schedules#autocomplete_schedule_event"
      get ':division' => "schedules#index", as: 'division', constraints: { division: /[A-Z]/ }
    end
  end

  resources :timeslots
  match '/schedule/:id/register/' => "signups#new", :as => :newsignup
  match '/schedule/:id/confirm/' => "signups#create", :as => :confirmsignup
  match '/signups/:id/delete/' => "signups#destroy", :as => :destroysignup
  match '/signups' => "signups#list", :as => :signups

  resources :tournaments do
    collection do
      post 'set_active'
    end

    get 'scores'
    get 'scoreslideshow'
    post 'publish_scores'
    post 'scoreslideshow'
    get 'load_default_events'
  end

  match '/login' => "teams#login"
  match '/login/:division' => "teams#login", :as => :login
  match '/logout' => "teams#logout"

  resources :info

  # Add the Static Pages
  ['about'].each do |static|
    match "/#{static}" => "home##{static}"
  end

  root :to => "home#index"
end
