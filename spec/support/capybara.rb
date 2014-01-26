require 'spec_helper'

shared_context '(capybara) visiting a tournament' do
  before do
    @tournament = FactoryGirl.create(:tournament, :current)
    Rails.application.routes.default_url_options[:subdomain] =
      @tournament.school.subdomain
  end
end
