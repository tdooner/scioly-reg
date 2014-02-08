require 'spec_helper'

shared_context 'as an admin of the tournament' do
  let(:admin_password) { ('a'..'z').to_a.sample(10).join }
  let(:admin) { FactoryGirl.create(:user, school: tournament.school, password: admin_password) }

  before do
    request.host = "#{tournament.school.subdomain}.lvh.me"
    session[:user_id] = admin.id
  end
end
