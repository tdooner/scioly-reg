source 'http://rubygems.org'

gem 'rails', '4.0.2'
gem 'haml'
gem 'breadcrumbs'
gem 'rdiscount'
gem 'recaptcha', :require => 'recaptcha/rails'
gem 'mixpanel'
gem 'paperclip'
gem 'aws-sdk'
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
  gem 'heroku_rails_deflate'
end

group :assets do
  gem 'sass'
  gem 'sass-rails'
  gem 'uglifier'
  gem 'yui-compressor'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'faker'
  gem 'timecop'
  gem 'mocha', require: false
  gem 'capybara'
  gem 'parallel_tests'
end

group :development do
  gem 'pry-byebug'
  gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'therubyracer'
end
