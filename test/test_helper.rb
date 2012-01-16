ENV['RAILS_ENV'] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'

Capybara.app_host = "http://test.lvh.me"

class ActiveSupport::TestCase
  include Capybara::DSL

  def setup
    @current_tournament = FactoryGirl.create(:current_tournament)
    @current_school = @current_tournament.school
    @other_tournament = FactoryGirl.create(:tournament)
  end

  FactoryGirl.define do
    factory :tournament do
      sequence(:date){|x| Time.now + x.years}
      registration_begins (Time.now - 2.days)
      registration_ends (Time.now + 2.days)
      is_current "false"
      school

      trait :current do
        is_current "true"
      end

      factory :current_tournament, :traits => [:current]
    end

    # school factory is in test/factories/schools.rb

    factory :team do
      sequence(:name){|x| "Nordonia High School - Team #{x}"}
      sequence(:number){|x| x.to_s}
      division "B"
      coach "Tom Dooner"
      password 'password'
      hashed_password Digest::SHA1.hexdigest('password')
      tournament
    end

    factory :user do
      # pass in a 
      sequence(:email){|x| "tom#{x}@example.com"}
      password "password"
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

  def assume_admin_login(school)
    visit '/user/login'
    admin = FactoryGirl.create(:user, :school => @current_school)
    fill_in "email", :with => admin.email
    fill_in "password", :with => admin.password
    click_link_or_button "Log In!"
  end

  def assume_team_login(team)
    team.password = Random.rand(1000000).to_s
    team.password_confirm = team.password
    assert team.save
    login_with_password(team, team.password)
    return team
  end

  def login_with_password(team, password)
    visit login_path(team.division)
    within("div#content") do
      assert current_path == login_path(team.division), "Current path is #{current_path}, not the login page #{login_path(team.division)}!"
      assert select(team.name, :from=>"team_id"), "Could not select team name on login page."
      fill_in "password", :with=>team.password
      find_button("Login").click
    end
    assert page.has_content?("Welcome")
    assert page.has_content?("Things To Do")
    assert page.has_content?("Your Information")
    assert !page.has_content?("Incorrect Password")
    assert (current_path == "" || current_path == "/"), "Path is wrong (#{current_path})."
  end
end

class ActionController::TestCase
  def setup 
    @current_school = FactoryGirl.create(:school)
    @current_tournament = FactoryGirl.create(:current_tournament, :school => @current_school)
    @other_tournament = FactoryGirl.create(:tournament, :school => @current_school)
    10.times do |t|
      FactoryGirl.create(:schedule, :tournament => @current_tournament)
      FactoryGirl.create(:team, :tournament => @current_tournament)
    end
  end
end
