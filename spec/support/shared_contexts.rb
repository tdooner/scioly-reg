require 'spec_helper'

shared_context 'as an admin of the tournament' do
  let(:admin_password) { ('a'..'z').to_a.sample(10).join }
  let(:user) { FactoryGirl.create(:user, password: admin_password) }
  let(:tournament) { FactoryGirl.create(:tournament, :current) }

  include_context 'visiting a school' do
    let(:school) { tournament.school }
  end

  before do
    Administration.create(user: user, administrates: school)
    session[:user_id] = user.id
  end
end

shared_context 'as a team in the tournament' do
  let(:team) { FactoryGirl.create(:team, tournament: tournament) }

  include_context 'visiting a school' do
    let(:school) { tournament.school }
  end

  before do
    session[:team] = team.id
  end
end

shared_context 'visiting a school' do
  before do
    the_school = if defined?(school)
                   school
                 else
                   if defined?(tournament)
                     tournament.school
                   else
                     FactoryGirl.create(:school)
                   end
                 end

    request.host = "#{the_school.subdomain}.lvh.me"
  end
end
