FactoryGirl.define do
  factory :schedule do
    event Faker::Name.name
    division 'B'
    room 'Crawford 111'
    starttime { tournament.date + 4.hours }
    endtime { tournament.date + 4.hours + 50.minutes }

    tournament

    trait :division_c do
      division "C"
    end

    factory :schedule_c, :traits => [:division_c]
  end
end
