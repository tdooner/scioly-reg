require 'test_helper'

class TeamsControllerTest < ActionController::TestCase
  test "Teams can log in." do
    team = FactoryGirl.create(:team)
    visit login_path(team.division)
    within("div.bluebox") do
      assert current_path == login_path(team.division), "Current path is #{current_path}, not the login page #{login_path(team.division)}!"
      assert select(team.name, :from=>"team_id"), "Could not select team name on login page."
      fill_in "password", :with=>team.password
      find_button("Login").click
    end
    assert page.has_content?("Welcome")
    assert !page.has_content?("Incorrect Password")
    assert (current_path == "" || current_path == "/"), "Path is wrong (#{current_path})."
  end
end
