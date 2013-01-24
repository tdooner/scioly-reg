FactoryGirl.define do
  factory :default_event do
    name Faker::Name.name
    division 'B'
    year 1900
  end
end
