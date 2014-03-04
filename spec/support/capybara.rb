require 'spec_helper'

shared_context '(capybara) visiting a tournament' do
  let(:registration_begins) { 7.days.ago }
  let(:registration_ends) { 1.days.ago }

  before do
    @tournament = FactoryGirl.create(:tournament, :current,
                                    registration_begins: registration_begins,
                                    registration_ends: registration_ends)
    Rails.application.routes.default_url_options[:subdomain] =
      @tournament.school.subdomain

    Capybara.app_host = "http://#{@tournament.school.subdomain}.example.com"
  end

  after do
    Rails.application.routes.default_url_options.delete(:subdomain)
  end
end

shared_context '(capybara) as a logged in team' do
  include_context '(capybara) visiting a tournament'

  before do
    @password = ('a'..'z').to_a.sample(8).join

    @team = FactoryGirl.create(:team, tournament: @tournament,
                                      hashed_password: Digest::SHA1.hexdigest(@password))
    visit login_teams_path
    expect(page).to have_content(@team.name)
    select(@team.name, from: 'team_id')
    fill_in 'password', with: @password
    click_button 'Login'
  end
end
