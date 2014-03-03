Scioly::Application.routes.draw do

  get "timeslots/update"

  resources :signups, only: [:new, :index, :destroy]

  namespace :admin do
    get 'index'
    get 'scores'
    get 'scorespublish', :as => :scorespublish
    get 'scoreslideshow'
    get "school/edit"
    patch "school/update"

    resources :schedules do
      get 'scores'
      post 'scores', action: 'savescores'

      collection do
        get 'all_pdfs'
        get 'batchnew' => "schedules#batchnew"
        post 'batchnew' => "schedules#batchcreate"
      end
    end

    resources :teams do
      get 'qualify' # TODO: this is broken

      collection do
        get 'batchnew' => 'teams#batchnew'
        post 'batchnew' => 'teams#batchcreate'
        post 'batchpreview'
      end
    end

    resources :tournaments do
      collection do
        post 'set_active'
      end

      post 'scoreslideshow'
      post 'publish_scores'
      get 'load_default_events'
    end
  end

  resource :user
  get "user/login", :as => :adminlogin
  post "user/login"
  get "user/logout", :as => :adminlogout

  resources :teams, only: [:show, :edit, :update] do
    collection do
      get 'login'
      get 'logout'
    end
  end

  match 'schools/new' => 'home#newschool', :via => [ :get ], :as => :new_school
  match 'schools/new' => 'home#createschool', :via => [ :post ]

  resources :schedules, :path => "/schedule", only: [:index, :show] do
    get 'scores'

    collection do
      get ':division' => "schedules#index", as: 'division', constraints: { division: /[A-Z]/ }
    end
  end

  resources :timeslots, only: [] do
    get 'register' => 'signups#new'
    get 'confirm' => 'signups#create'
  end

  resources :timeslots

  resources :tournaments, only: [] do
    get 'scores'
  end

  resources :info

  # Add the Static Pages
  ['about'].each do |static|
    match "/#{static}" => "home##{static}", via: [:get]
  end

  root :to => "home#index"
end
