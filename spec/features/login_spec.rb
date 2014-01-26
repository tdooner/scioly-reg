require 'spec_helper'

describe 'the login process' do
  context 'with a team' do
    include_context '(capybara) visiting a tournament'

    let(:password) { 'somePassword' }
    let(:team) do
      FactoryGirl.create(:team, tournament: @tournament,
                                hashed_password: Digest::SHA1.hexdigest(password))
    end

    it 'allows the team to log in' do
      visit login_url(team.division)
      expect(page).to have_content(team.name)
      select(team.name, from: 'team_id')
      fill_in 'password', with: password
      click_button 'Login'
      expect(page).to have_content("Welcome, #{team.name}")
    end

    it 'denies teams entry with invalid password' do
      visit login_url(team.division)
      expect(page).to have_content(team.name)
      select(team.name, from: 'team_id')
      fill_in 'password', with: password + 'nope'
      click_button 'Login'
      expect(page).to have_content('Incorrect Password')
    end
  end
end
