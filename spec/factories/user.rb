FactoryGirl.define do
  factory :user do
    sequence(:email) { |x| "tom#{x}@example.com" }
    password "password"
  end
end
