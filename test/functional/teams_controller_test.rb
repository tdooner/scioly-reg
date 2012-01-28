require 'test_helper'

class TeamsControllerTest < ActionController::TestCase

  test "Teams can log in." do
    assert @team = assume_team_login(@current_tournament.teams.first)
  end

  test "Team helper." do
    @team = FactoryGirl.create(:team, :tournament => @current_tournament)
    assert login_with_password(@team, @team.password)
    assert !login_with_password(@team, @team.password + ".")
  end 

  test "Team may change their password." do
    @team = Team.first
    @team = assume_team_login(@team)
    pw_before = @team.password
    pw_hash_before = @team.hashed_password
    new_pw = Random.rand(1000000).to_s 
    click_link("Change Password")
    fill_in("team[password_existing]", :with=>@team.password)
    fill_in("team_password", :with=>new_pw)
    fill_in("team_password_confirmation", :with=>new_pw)
    click_button("Update Team")
    assert !page.has_content?("Incorrect")
    click_link("Logout")
    assert !login_with_password(@team, pw_before), "Team can log in with old password!"
    assert login_with_password(@team, new_pw), "Team cannot log in with new password!"
    click_link(@team.name)
    assert !page.has_content?("Incorrect Password")
    assert page.has_content?("Things To Do"), "Page does not contain 'Things To Do'"
    assert page.has_content?("Your Information")
    assert @team.reload.hashed_password != pw_hash_before, "Password not actually changed!"
  end
end
