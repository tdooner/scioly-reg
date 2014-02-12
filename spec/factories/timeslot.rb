FactoryGirl.define do
  factory :timeslot do
    sequence(:begins) { |n| schedule.starttime + (5 * n).minutes }
    sequence(:ends)   { |n| schedule.starttime + (5 * (n + 1) - 1).minutes }
    team_capacity 3

    schedule
  end
end
