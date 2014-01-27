require 'spec_helper'

shared_context 'as an admin of the tournament' do
  let(:admin) { FactoryGirl.create(:user, school: tournament.school) }

  before do
    request.host = "#{tournament.school.subdomain}.lvh.me"
    session[:user_id] = admin.id
  end
end
