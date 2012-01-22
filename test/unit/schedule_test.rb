require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase
  def setup
    @current_tournament = FactoryGirl.create(:current_tournament)
    @schedule = FactoryGirl.create(:schedule, :tournament => @current_tournament)
  end

  test "A valid schedule should save properly." do
    schedule_this = FactoryGirl.build(:schedule, :tournament => @current_tournament)
    assert schedule_this.valid?, "Invalid valid schedule!"
    assert schedule_this.save(), "Valid schedule failed to save"
  end

  test "Updating a schedule's attributes should work." do
    assert @schedule.update_attribute(:event, @schedule.event + "new")
    assert @schedule.update_attribute(:room, @schedule.room + "new")
  end

  test "updateTimeSlots does nothing with no input" do
    num_slots = Timeslot.all.length
    # num_timeslots and teams_per_slot are not initialized here:
    assert @schedule.updateTimeSlots.is_a?(String), "UpdateTimeSlots didn't Error..?"
    assert Timeslot.all.length == num_slots, "Timeslots created when it shouldn't have."
    assert @schedule.timeslots.empty?, "Event has timeslots when it shouldn't."

    #initialze teams_per_slot, but not num_timeslots
    @schedule.teams_per_slot = 2
    assert @schedule.updateTimeSlots.is_a?(String), "UpdateTimeSlots didn't error...?"

    # set num_timeslots == 0
    @schedule.num_timeslots = 0
    assert @schedule.updateTimeSlots.is_a?(String) || @schedule.updateTimeSlots.length == 0, "UpdateTimeSlots didn't error or created some timeslots."
  end

  test "updateTimeSlots creates correct number of timeslots" do
    num_slots = Timeslot.all.length
    @schedule.num_timeslots = 15
    assert @schedule.updateTimeSlots.is_a?(Array), "UpdateTimeSlots error!"
    assert @schedule.timeslots.reload.length == 15, "UpdateTimeSlots should make #{@schedule.num_timeslots} but made #{@schedule.timeslots.reload.length}."
    assert Timeslot.all.length == num_slots + 15, "Timeslot was #{num_slots} before adding 15, and is now #{Timeslot.all.length}"
  end

  test "updateTimeSlots creates timeslots that have correct team_capacity" do
    @schedule.num_timeslots = 15
    tps = 1 + Random.rand(10)
    @schedule.teams_per_slot = tps
    assert @schedule.updateTimeSlots.is_a?(Array)
    assert @schedule.timeslots.length == 15
    @schedule.timeslots.each{|s| assert s.team_capacity == tps}
  end

  test "updateTimeSlots removes all previous timeslots on update" do
    num_slots = Timeslot.all.length
    (1..3).each do |n|
      @schedule.num_timeslots = n*5
      assert @schedule.updateTimeSlots.is_a?(Array), "Error in updateTimeSlots!"
      assert @schedule.timeslots.reload.length == n*5, "Old timeslots still associated"
      assert Timeslot.all.length == (num_slots + n*5), "Old timeslots not deleted"
    end
  end

  test "updateTimeSlots produces slots only in the duration" do
    @schedule.num_timeslots = 20
    assert @schedule.updateTimeSlots.is_a?(Array), "UpdateTimeSlots Error!"
    assert @schedule.timeslots.reload.length == 20, "Incorrect number of timeslots created."
    @schedule.timeslots.each do |t|
      assert t.begins >= @schedule.starttime && t.ends <= @schedule.endtime
    end
  end

  test "Returns the correct value for if a team has registered." do
    team = FactoryGirl.create(:team, :tournament => @current_tournament)
    # Team has not registered for the schedule
    assert !@schedule.hasTeamRegistered(team)
  end

end
