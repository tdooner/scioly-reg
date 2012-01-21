require 'test_helper'

class TimeslotTest < ActiveSupport::TestCase
  test "Timeslots don't save if they have no schedule, times, or capacity." do
    event = @current_tournament.schedules.first
    assert !Timeslot.new({:schedule => event, :begins => @current_tournament.date + 2.hours, :ends => @current_tournament.date + 2.hours + 50.minutes}).save, "Timeslot saved with no team capacity!"
    assert !Timeslot.new({:schedule => event, :begins => @current_tournament.date + 2.hours, :team_capacity => 10}).save, "Timeslot saved with no end time!"
    assert !Timeslot.new({:schedule => event, :ends => @current_tournament.date + 2.hours, :team_capacity => 10}).save, "Timeslot saved with no begin time!"
    assert !Timeslot.new({:begins => @current_tournament.date + 2.hours, :ends => @current_tournament.date + 2.hours + 50.minutes, :team_capacity => 10}).save, "Timeslot saved with no schedule!"
  end
end
