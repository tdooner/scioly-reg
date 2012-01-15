require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "Admin Control Panel Link Displays" do
    assume_admin_login(@current_school)
    visit '/'
    assert page.has_content?("Admin Panel")
  end
end
