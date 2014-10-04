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
      get 'qualify'

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

  resource :session, only: %i[create destroy]

  resources :users, id: /\d+/ do
    collection do
      resources :forgotten_email, only: %i[new] do
        post 'show', on: :collection
      end

      resources :password_reset, only: %i[create new] do
        get 'choose_password', on: :collection
        post 'set_new_password', on: :collection
      end

      get 'login'
    end
  end

  resources :teams, only: [:show, :edit, :update] do
    collection do
      match 'login', via: [:get, :post]
      get 'logout'
    end
  end

  resources :schools, only: [:new, :create]

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
    get "/#{static}" => "home##{static}"
  end

  constraints subdomain: '' do
    get '/' => "home#index"
  end

  get '/' => 'tournaments#show', as: :root
end
