FactoryGirl.define do
  factory :tournament do
    sequence(:date) { |x| Date.today + x.days }
    registration_begins { date - 3.weeks }
    registration_ends { date - 1.day }
    is_current false
    sequence(:title) { |x| "tournament #{x}'s title" }
    divisions %w[B C]

    school

    trait :current do
      is_current true
    end

    trait :open_for_registration do
      registration_begins { Date.today - 3.days }
      registration_ends { Date.today + 3.days }
    end

    factory :current_tournament, :traits => [ :current ]
  end
end
