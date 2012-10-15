Scioly::Application.routes.draw do

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
  end

  resource :user
  get "user/login", :as => :adminlogin
  post "user/login"
  get "user/logout", :as => :adminlogout
  match 'teams/batchnew' => "teams#batchnew", :via=>[:get]
  match 'teams/batchnew' => "teams#batchcreate", :via=>[:post]
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

  # Add the Static Pages
  ['about'].each do |static|
    match "/#{static}" => "home##{static}"
  end

  root :to => "home#index"
end
