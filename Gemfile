source 'http://rubygems.org'
ruby '2.0.0'

gem 'rails', '4.0.2'
gem 'haml'
gem 'breadcrumbs'
gem 'rdiscount'
gem 'recaptcha', :require => "recaptcha/rails"
gem 'mixpanel'
gem "paperclip"
gem "aws-sdk"
gem 'aws-s3'
gem 'premailer-rails'
gem 'nokogiri'
gem 'airbrake'
gem 'jquery-rails'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'
gem 'turbolinks'
gem 'newrelic_rpm'

group :production do
  gem 'pg'
  gem 'unicorn'
  gem 'rails_12factor'
  gem 'font_assets'
end

group :assets do
  gem 'sass'
  gem 'sass-rails'
  gem 'uglifier'
  gem 'yui-compressor'
end

group :test do
    gem 'factory_girl_rails'
    gem 'rspec-rails'
    gem 'faker'
    gem 'timecop'
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
