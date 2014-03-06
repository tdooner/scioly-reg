require 'spec_helper'

shared_context 'as an admin of the tournament' do
  let(:admin_password) { ('a'..'z').to_a.sample(10).join }
  let(:admin) { FactoryGirl.create(:user, school: tournament.school, password: admin_password) }

  include_context 'visiting a school' do
    let(:school) { tournament.school }
  end

  before do
    session[:user_id] = admin.id
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
    request.host = "#{school.subdomain}.lvh.me"
  end
end
