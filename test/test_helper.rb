require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'

class ActiveSupport::TestCase
  include Capybara::DSL

  FactoryGirl.define do
    factory :tournament do
      date "2012-02-26"
      is_current true
      registration_begins Time.now - 2.days
      registration_ends Time.now + 2.days
    end
    factory :team do
      name "Nordonia High School - Team 1"
      number "33"
      division "B"
      coach "Tom Dooner"
      password 'password'
      hashed_password Digest::SHA1.hexdigest('password')
      tournament
    end
  end
end
