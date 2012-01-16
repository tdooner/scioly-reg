require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase
  test "A valid schedule should save properly." do
    schedule = FactoryGirl.build(:schedule, :tournament => @current_tournament)
    assert schedule.valid?, "Invalid valid schedule!"
    assert schedule.save(), "Valid schedule failed to save"
  end
end
