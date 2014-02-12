FactoryGirl.define do
  factory :schedule do
    event { Faker::Name.name }
    division 'B'
    room 'Crawford 111'
    starttime { tournament.date + 4.hours }
    endtime { tournament.date + 4.hours + 50.minutes }

    tournament

    trait :division_c do
      division "C"
    end

    factory :schedule_c, :traits => [:division_c]

    trait :with_timeslots do
      after(:create) do |schedule|
        3.times { FactoryGirl.create(:timeslot, schedule: schedule) }
      end
    end
  end
end
