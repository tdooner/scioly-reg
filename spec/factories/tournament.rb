FactoryGirl.define do
  factory :tournament do
    sequence(:date) { |x| Date.today + x.days }
    registration_begins { date - 3.weeks }
    registration_ends { date - 1.day }
    is_current false
    sequence(:title) { |x| "tournament #{x}'s title" }

    school

    trait :current do
      is_current true
    end

    factory :current_tournament, :traits => [ :current ]
  end
end
