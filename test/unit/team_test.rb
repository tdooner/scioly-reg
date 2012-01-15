require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  def setup
    @team = FactoryGirl.build(:team)
  end

  test "A valid team can be saved to the database." do
    assert @team.valid?, "Test case is not valid!"
    assert @team.save(), "Team did not save."
  end

  test "A team without a Division is invalid." do
    @team.division = nil
    assert !@team.valid?
  end

  test "A team is valid iff password_confirmation matches its password" do
    @team.password = "abcdef"
    @team.password_confirm = "abcdef"
    assert @team.valid?, "Team is invalid with identical passwords!"
    @team.password_confirm = "ghijkl"
    assert !@team.valid?, "Team is valid with differing passwords!"
  end

  test "A password hash is encrypted correctly." do
    assert Team.encrypt(@team.password) == @team.hashed_password
  end

  test "A valid team can be authenticated." do
    assert @team == Team.authenticate(@team.id, @team.password)
  end

  test "Can update appropriate attributes." do
    assert @team.update_attribute(:name, @team.name + "new")
    assert @team.update_attribute(:number, @team.number.to_i + 1)
    assert @team.update_attribute(:coach, "different" + @team.coach)
    assert @team.update_attribute(:homeroom, "different " + @team.homeroom.to_s)
    # Ensure hashed_password is not mass-settable
    before = @team.hashed_password
    @team.update_attributes({:hashed_password => "abcdef12346"})
    assert @team.hashed_password == before

    # Change password!
    newpw = "testing_password"
    @team.password = newpw
    @team.password_confirm = newpw
    assert @team.save
    assert @team.reload.hashed_password == Team.encrypt(newpw)
  end

  test "A new team should have all events unregistered." do
    10.times do |t|
      FactoryGirl.create(:schedule, :tournament => @current_tournament)
    end
    all_events = @team.tournament.schedules.where(["division=?", @team.division]).keep_if(&:is_scheduled_online?)
    e = @team.unregistered_events
    assert e == all_events
  end
end
