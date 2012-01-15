require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "A valid team can be saved to the database." do
    team = FactoryGirl.build(:team)
    assert team, "FactoryGirl failed"
    assert team.valid?, "Team is not valid! #{team.errors.full_messages.first}."
    assert team.save(), "Team did not save."
  end

  test "A valid team can be authenticated." do
    team = FactoryGirl.create(:team)
    assert team == Team.authenticate(team.id, team.password)
  end
end
