FactoryGirl.define do
  factory :timeslot do
    begins { schedule.starttime + 5.minutes }
    ends { schedule.starttime + 15.minutes }
    team_capacity 3

    schedule
  end
end
