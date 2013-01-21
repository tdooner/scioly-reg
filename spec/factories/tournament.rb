FactoryGirl.define do
  factory :tournament do
    sequence(:date) { |x| Time.now + x.years }
    registration_begins { date - 3.weeks }
    registration_ends { date - 1.day }
    is_current false

    school

    trait :current do
      is_current true
    end

    factory :current_tournament, :traits => [ :current ]
  end
end
