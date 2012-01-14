ENV['RAILS_ENV'] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'

class ActiveSupport::TestCase
  include Capybara::DSL

  def setup
    @current_tournament = FactoryGirl.create(:current_tournament)
    @other_tournament = FactoryGirl.create(:tournament)
  end

  FactoryGirl.define do
    factory :tournament do
      sequence(:date){|x| Time.now + x.years}
      registration_begins (Time.now - 2.days)
      registration_ends (Time.now + 2.days)
      is_current "false"

      trait :current do
        is_current "true"
      end

      factory :current_tournament, :traits => [:current]

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
    factory :user do
      case_id "ted27"
      role 1
    end
    factory :schedule do
      event Faker::Name.name
      division "B"
      room "Crawford 111"
      tournament
      starttime (Time.now + 7.hours)
      endtime (Time.now + 7.hours + 50.minutes)

      trait :division_c do
        division "C"
      end

      factory :schedule_c, :traits => [:division_c]
    end
  end

  def assume_admin_login
    RubyCAS::Filter.fake( FactoryGirl.create(:user).case_id )
    visit '/user/login'
  end
end

class ActionController::TestCase
  def setup 
    @current_tournament = FactoryGirl.create(:current_tournament)
    @other_tournament = FactoryGirl.create(:tournament)
    10.times do |t|
      FactoryGirl.create(:schedule, :tournament => @current_tournament)
    end
  end
end
