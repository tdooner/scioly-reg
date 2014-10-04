require 'spec_helper'

describe PasswordResetController do
  let(:tournament) { FactoryGirl.create(:current_tournament) }
  include_context 'visiting a school' do
    let(:school) { tournament.school }
  end

  render_views

  describe '#new' do
    it 'renders' do
      get :new
      response.should be_success
    end
  end

  describe '#create' do
    let(:user) { FactoryGirl.create(:user) }
    let(:params) { { email: user.email } }

    subject { post :create, params }

    before { ActionMailer::Base.deliveries.clear }

    it 'sends email' do
      subject
      ActionMailer::Base.deliveries.should_not be_empty
    end

    it 'sets the reset token and includes it in the email' do
      subject

      reset_token = user.reload.reset_token
      reset_token.should_not be_blank
      ActionMailer::Base.deliveries.first.html_part.body.encoded.should include(reset_token)
    end
  end

  describe '#choose_password' do
    let(:user) { FactoryGirl.create(:user) }
    let(:reset_token) { user.set_reset_token! }

    subject { get :choose_password, params }

    context 'with valid reset token' do
      let(:params) { { user_id: user.id, reset_token: reset_token } }

      it 'renders' do
        subject
        response.should be_success
      end
    end

    context 'with an invalid reset token' do
      let(:params) { { user_id: user.id, reset_token: reset_token + 'foo' } }

      it 'redirects' do
        subject
        response.should be_redirect
      end
    end

    context 'with an invalid team' do
      let(:other_user) { FactoryGirl.create(:user) }
      let(:params) { { user_id: other_user.id, reset_token: reset_token } }

      it 'redirects' do
        subject
        response.should be_redirect
      end
    end
  end

  describe '#set_new_password' do
    let(:user) { FactoryGirl.create(:user) }
    let!(:reset_token) { user.set_reset_token! }
    let(:new_password) { 'foobarbazhellllllllo' }

    subject { post :set_new_password, params }

    context 'with a valid reset token' do
      let(:params) do
        {
          user_id: user.id,
          reset_token: reset_token,
          password: new_password,
          password_confirmation: new_password
        }
      end

      it 'resets the password' do
        subject

        User.authenticate(user.email, new_password).should == user
      end
    end

    context 'with an invalid reset token' do
      let(:params) do
        {
          user_id: user.id,
          reset_token: reset_token + 'lalala',
          password: new_password,
          password_confirmation: new_password
        }
      end

      it 'does not change the password' do
        subject

        User.authenticate(user.email, new_password).should be_blank
      end
    end

    context 'after the reset token expires' do
      let(:params) do
        {
          user_id: user.id,
          reset_token: reset_token,
          password: new_password,
          password_confirmation: new_password
        }
      end

      before { user.update_attribute(:reset_token_sent_at, 2.hours.ago) }

      it 'does not change the password' do
        subject

        User.authenticate(user.email, new_password).should be_blank
      end
    end
  end
end
