require 'spec_helper'

describe HomeController do
  describe 'createschool action' do
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
    end
  end
end
