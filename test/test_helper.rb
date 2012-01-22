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

  def populate_tournament(t)
    10.times do |n|
      FactoryGirl.create(:schedule, :tournament => t)
      FactoryGirl.create(:team, :tournament => t)
    end
    return true
  end

  def populate_scores(t)
    t.schedules.each_with_index do |schedule, i|
      scores = (1..t.teams.length).to_a.shuffle
      scores.each_with_index do |placement, d|
        score = Score.new({:schedule => schedule, :team => t.teams[d], :placement => placement})
        return false unless score.save
      end
    end
    return true
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

      trait :occurred do
        date { Time.now - 1.day }
      end

      factory :current_tournament, :traits => [:current]
    end

    # school factory is in test/factories/schools.rb

    factory :team do
      sequence(:name){|x| Faker::Company.name + " - Team #{x}"}
      sequence(:number){|x| x.to_s}
      division "B"
      coach "Tom Dooner"
      password 'password'
      password_confirmation 'password'
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
    new_pw = Random.rand(1000000).to_s
    team.password = new_pw
    team.password_confirmation = new_pw
    assert team.save
    assert login_with_password(team, new_pw)
    return team
  end

  def login_with_password(team, password)
    visit login_path(team.division)
    within("div#content") do
      return false unless current_path == login_path(team.division)
      return false unless select(team.name, :from=>"team_id")
      fill_in "password", :with=>password
      find_button("Login").click
    end
    return false if page.has_content?("Incorrect Password")

    # Things that the default team login page has:
    return false unless page.has_content?("Welcome")
    return false unless page.has_content?("Things To Do")
    return false unless page.has_content?("Your Information")
    return false unless (current_path == "" || current_path == "/")

    return true
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
