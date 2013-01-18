FactoryGirl.define do
  factory :team do
    sequence(:name) { |x| "Nordonia High School - Team #{x}" }
    sequence(:number) { |x| x.to_s }
    division "B"
    coach "Tom Dooner"
    password 'password'
    hashed_password Digest::SHA1.hexdigest('password')

    tournament
  end
end
