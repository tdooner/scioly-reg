require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  test "A valid team can be saved to the database." do
    @team = FactoryGirl.build(:team)
    assert @team.valid?, "Test case is not valid!"
    assert @team.save(), "Team did not save."
  end

  test "A team without a Division is invalid." do
    @team = FactoryGirl.build(:team)
    @team.division = nil
    assert !@team.valid?
  end

  test "A team is valid iff password_confirmation matches its password" do
    @team = FactoryGirl.build(:team)
    @team.password = "abcdef"
    @team.password_confirmation = "abcdef"
    assert @team.valid?, "Team is invalid with identical passwords!"
    @team.password_confirmation = "ghijkl"
    assert !@team.valid?, "Team is valid with differing passwords!"
  end

  test "A password hash is encrypted correctly." do
    @team = FactoryGirl.build(:team)
    assert Team.encrypt(@team.password) == @team.hashed_password
  end

  test "A valid team can be authenticated." do
    @team = FactoryGirl.build(:team)
    assert @team.save, "Team is not valid!"
    assert @team == Team.authenticate(@team.id, @team.password)
  end

  test "Can update appropriate attributes." do
    @team = FactoryGirl.create(:team)
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
    @team.password_confirmation = newpw
    assert @team.save
    assert @team.reload.hashed_password == Team.encrypt(newpw)
  end

  test "A new team should have all events unregistered." do
    assert populate_tournament(@current_tournament)

    @team = FactoryGirl.build(:team)
    all_events = @team.tournament.schedules.where(["division=?", @team.division]).keep_if(&:is_scheduled_online?)
    e = @team.unregistered_events
    assert e == all_events
  end

  test "A team's total_points is the sum of its placements from non-trial events." do
    assert populate_tournament(@current_tournament) && populate_scores(@current_tournament)

    # Verify all the scores.
    @current_tournament.teams.each do |team|
      sum_of_scores = team.scores.map(&:placement).sum
      assert team.total_points == sum_of_scores, "Event placement math doesn't add up correctly."
    end

    # Now verify the scores with some of the events marked as trial events.
    @current_tournament.schedules.first.update_attribute(:counts_for_score, false)
    @current_tournament.schedules.last.update_attribute(:counts_for_score, false)
    @current_tournament.teams.each do |team|
      sum_of_scores = team.scores.map{|x| x.schedule.counts_for_score ? x.placement : 0}.sum
      assert team.total_points == sum_of_scores, "Trial events math doesn't add up correctly. Should be #{sum_of_scores} and is #{team.total_points}."
    end
  end

  test "The first element in a team's rank_matrix is its total points." do
    assert populate_tournament(@current_tournament) && populate_scores(@current_tournament)

    @current_tournament.teams.each do |x|
      assert x.rank_matrix[0] == x.total_points
    end
  end

  test "Deleting a team deletes all its sign_ups" do
    assert populate_tournament(@current_tournament)
    event = @current_tournament.schedules.first
    event.num_timeslots = 10
    event.teams_per_slot = 2
    team = @current_tournament.teams.first
    assert event.updateTimeSlots.is_a?(Array), "Couldn't create timeslots!?"
    sign_up = SignUp.new({:timeslot => event.timeslots.first, :team => team})
    assert sign_up.save
    total_signups = SignUp.count
    team.delete    
    assert sign_up.destroyed?, "Sign Up not marked as destroyed!"
    assert team.sign_ups.length == 0, "Team still has Sign Ups associated!"
    assert SignUp.count == total_signups - 1, "Expected to see #{total_signups - 1} SignUps but found #{SignUp.count}"
  end
end
