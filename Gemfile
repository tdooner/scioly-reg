source 'http://rubygems.org'
ruby '2.0.0'

gem 'rails', '3.2.16'
gem 'haml'
gem 'breadcrumbs'
gem 'rdiscount'
gem 'recaptcha', :require => "recaptcha/rails"
gem 'mixpanel'
gem "paperclip"
gem "aws-sdk"
gem 'aws-s3'
gem 'premailer-rails3'
gem 'nokogiri'
gem 'airbrake'
gem 'jquery-rails'
gem 'rails3-jquery-autocomplete'

group :production do
  gem 'pg'
  gem 'unicorn'
end

group :assets do
  gem 'sass'
  gem 'sass-rails'
end

group :test do
    gem 'factory_girl_rails'
    gem 'rspec-rails'
    gem 'faker'
    gem 'capybara'
    gem 'time-warp'
    gem 'mocha', require: false
    gem 'capybara'
end
gem "parallel_tests"

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# Bundle the extra gems:
# gem 'bj'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development do
  gem 'debugger'
  gem 'sqlite3-ruby', :require => 'sqlite3'
end
