FactoryGirl.define do
  factory :user do
    sequence(:email) { |x| "tom#{x}@example.com" }
    password "password"
    role 1
  end
end
