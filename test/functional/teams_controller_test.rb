require 'test_helper'

class TeamsControllerTest < ActionController::TestCase
  test "Teams can log in." do
    @team = assume_team_login(Team.first)
  end

  test "Team may change their password." do
    # Note, this test does not pass.
    @team = Team.first
    @team = assume_team_login(@team)
    STDERR.write("PW=#{@team.password}")
    STDERR.write("#{@team.inspect}")
    new_pw = Random.rand(1000000).to_s 
    click_link("Change Password")
    fill_in("team_password_existing", :with=>@team.password)
    fill_in("team_password", :with=>new_pw)
    fill_in("team_password_confirm", :with=>new_pw)
    click_button("Update Team")
    assert !page.has_content?("Incorrect")
    click_link("Logout")
    login_with_password(@team, new_pw)
    STDERR.write("PW=#{@team.password}")
    assert page.has_content?("Things To Do")
    assert page.has_content?("Your Information")
    assert !page.has_content?("Incorrect Password")
  end
end
