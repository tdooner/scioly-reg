require 'test_helper'

class SignUpTest < ActiveSupport::TestCase
  def setup
    @current_tournament = FactoryGirl.create(:current_tournament)
    (1..10).each do |t|
      s = FactoryGirl.create(:schedule, :tournament => @current_tournament)
      s.num_timeslots = t*3
      s.teams_per_slot = 2
      s.updateTimeSlots
      FactoryGirl.create(:team, :tournament => @current_tournament)
    end
  end

  test "A team can sign up in a timeslot" do
    t = Team.first
    ts = Schedule.first.timeslots.first
    sign_up = SignUp.new({:team => t, :timeslot => ts})
    assert sign_up.save
  end

  test "Only up to the correct number of teams may sign up in a timeslot" do
    ts = Timeslot.first
    Team.all.length.times do |n|
      team = Team.all[n]
      sign_up = SignUp.new({:team => team, :timeslot => ts})
      if (n+1) <= ts.team_capacity
        assert sign_up.save, "#{n} teams signed up in a timeslot with capacity #{ts.team_capacity}"
      else
        assert !sign_up.save, "Team ##{n} could not sign up in a timeslot with capacity #{ts.team_capacity}"
      end
    end
  end

  test "A team may not sign up twice for one event or in one timeslot." do
    schedule = Schedule.all.shuffle.first
    ts1 = schedule.timeslots.first
    ts2 = schedule.timeslots.last
    assert ts1 != ts2, "Testing error: schedule has zero or one timeslot."
    # Signing up twice in different timeslots
    assert SignUp.new({:team=>Team.first, :timeslot=>ts1}).save
    assert !SignUp.new({:team=>Team.first, :timeslot=>ts2}).save
    # Signing up twice in the same timeslot
    assert SignUp.new({:team=>Team.last, :timeslot=>ts1}).save
    assert !SignUp.new({:team=>Team.last, :timeslot=>ts1}).save
  end
end
