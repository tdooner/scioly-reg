require 'spec_helper'

describe HomeController do
  describe 'createschool action' do
    before do
      HomeMailer.stubs(:welcome).returns(stub(:deliver => ''))
    end

    context 'with valid form data' do
      let(:formdata) {
      {
        "school" => {
          "name"        => "test",
          "time_zone"   => "Eastern Time (US & Canada)",
          "admin_name"  => "Testing",
          "admin_email" => "test@test.com",
          "subdomain"   => "test"
        },
        "tournament" => {
          "title"    => "testing",
          "date(2i)" => "4",
          "date(3i)" => "18",
          "date(1i)" => "2013"
        },
        "tournament_director" => {
          "password"              => "password",
          "password_confirmation" => "password"
        },
        "commit" => "Sign Up!"
      }
      }

      it 'creates the school' do
        post :createschool, formdata
        response.should render_template(:createdschool)
      end

      it 'prepoulates the created tournament with events' do
        Tournament.any_instance.expects(:load_default_events)
        post :createschool, formdata
      end

      it 'sends an email to welcome the coach' do
        HomeMailer.expects(:welcome => stub(:deliver => '')).
          with('test@test.com')
        post :createschool, formdata
      end
    end
  end
end
