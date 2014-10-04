require 'spec_helper'

describe ForgottenEmailController do
  let(:tournament) { FactoryGirl.create(:current_tournament) }
  include_context 'visiting a school' do
    let(:school) { tournament.school }
  end

  render_views

  describe '#new' do
    subject { get :new }

    it 'renders' do
      subject
      response.should be_success
    end
  end

  describe '#show' do
    let(:team) { FactoryGirl.create(:team, tournament: tournament) }
    let(:user) { FactoryGirl.create(:user) }
    let(:password) { team.password }

    before { Administration.create(user: user, administrates: team) }

    subject { post :show, params }

    describe 'with a correct password' do
      let(:params) { { team: { id: team.id }, password: password } }

      it 'shows the email address of the user' do
        subject
        response.body.should include(user.email)
      end
    end

    describe 'with a password for another teams user' do
      let(:other_team) { FactoryGirl.create(:team, tournament: tournament) }
      let(:other_user) { FactoryGirl.create(:user) }

      before { Administration.create(user: user, administrates: team) }

      let(:params) { { team: { id: other_team.id }, password: password } }

      it 'redirects' do
        subject
        response.should be_redirect
        response.body.should_not include(other_user.email)
      end
    end

    describe 'with an incorrect password for a correct user' do
      let(:password) { 'incorrect password' }
      let(:params) { { team: { id: team.id }, password: password } }

      it 'redirects' do
        subject
        response.should be_redirect
        response.body.should_not include(user.email)
      end
    end
  end
end
