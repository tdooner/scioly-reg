FactoryGirl.define do
  factory :timeslot do
    begins { Time.now }
    ends { Time.now + 30.minutes }
    team_capacity 4
    schedule
  end
end
