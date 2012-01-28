require 'test_helper'

class TimeslotTest < ActiveSupport::TestCase
  test "Timeslots don't save if they have no schedule, times, or capacity." do
    event = @current_tournament.schedules.first
    assert !Timeslot.new({:schedule => event, :begins => @current_tournament.date + 2.hours, :ends => @current_tournament.date + 2.hours + 50.minutes}).save, "Timeslot saved with no team capacity!"
    assert !Timeslot.new({:schedule => event, :begins => @current_tournament.date + 2.hours, :team_capacity => 10}).save, "Timeslot saved with no end time!"
    assert !Timeslot.new({:schedule => event, :ends => @current_tournament.date + 2.hours, :team_capacity => 10}).save, "Timeslot saved with no begin time!"
    assert !Timeslot.new({:begins => @current_tournament.date + 2.hours, :ends => @current_tournament.date + 2.hours + 50.minutes, :team_capacity => 10}).save, "Timeslot saved with no schedule!"
  end

  test "Deleting a timeslot deletes all its sign_ups" do
    s1 = FactoryGirl.build(:sign_up)
    s1.timeslot.schedule.tournament.set_current
    s1.team.update_attribute(:tournament, s1.timeslot.schedule.tournament)
    assert s1.save, "SignUp did not save -- #{s1.errors.full_messages.first}"

    timeslot = s1.timeslot 
    num = SignUp.count
    timeslot.destroy
    assert !SignUp.find_by_id(s1.id), "SignUp #{s1.inspect} not marked as destroyed."
    assert SignUp.count < num, "Sign Up #{s1.inspect} still exists in database!"
    assert timeslot.sign_ups.reload.empty?, "SignUp #{s1.inspect} still associated."
  end
end
