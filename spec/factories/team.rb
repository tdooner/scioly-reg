FactoryGirl.define do
  factory :team do
    sequence(:name) { |x| "#{Faker::Address.city} High School - Team #{x}" }
    sequence(:number) { |x| x.to_s }
    division "B"
    coach { Faker::Name.name }
    password 'password'
    hashed_password Digest::SHA1.hexdigest('password')
    email Faker::Internet.email
    qualified false

    tournament
  end
end
