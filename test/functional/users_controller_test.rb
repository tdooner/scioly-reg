require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "Admin Control Panel Link Displays" do
    assume_admin_login
    visit '/'
    assert page.has_content?("Admin Panel")
  end
end
