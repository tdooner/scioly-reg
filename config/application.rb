require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'rdiscount'

if defined?(Bundler)
  Bundler.require(:default, Rails.env)
end

ActiveRecord::Base.include_root_in_json = false

Raven.configure do |config|
  if ENV['SENTRY_DSN']
    config.dsn = ENV['SENTRY_DSN']
  elsif ENV['RAILS_ENV'] == 'production'
    Rails.logger.error "NO VALUE IN ENV['SENTRY_DSN']"
  end
end

module Scioly
  class Application < Rails::Application
    # Remove for Rails 4.1:
    config.secret_key_base =
      YAML.load_file('config/secrets.yml')[Rails.env]['secret_key_base']
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    config.assets.enabled = true
    config.assets.initialize_on_precompile = false
    config.assets.precompile += %w(slidy.css slidy.js)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.i18n.enforce_available_locales = true
  end
end

Rails.application.routes.default_url_options[:host] = 'sciolyreg.org'
