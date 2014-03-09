Scioly::Application.config.session_store :cookie_store,
  key: '_foundry',
  domain: (Rails.env.development? ? '.lvh.me' : :all)
