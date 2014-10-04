require 'spec_helper'

describe SessionsController do
  describe '#create' do
    let(:user) { FactoryGirl.create(:user) }

    subject { post :create, params }

    context 'with a valid username / password' do
      let(:params) { { email: user.email, password: user.password } }

      it 'sets the user_id session key' do
        subject
        session[:user_id].should == user.id
      end

      it 'redirects to root' do
        subject.should redirect_to(root_path)
      end
    end

    context 'with an invalid username / password' do
      let(:params) { { email: user.email, password: user.password + '.' } }

      it 'does not set the user_id session key' do
        subject
        session[:user_id].should be_nil
      end

      it 'redirects to login page' do
        subject.should redirect_to(login_users_path)
      end
    end
  end
end
