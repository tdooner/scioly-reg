FactoryGirl.define do
  factory :school do
    sequence(:name) {|x| "Nordonia High School #{x}"}
    sequence(:subdomain) { |x| ('a'..'z').to_a.sample(10).join }
    admin_name "Tom Dooner"
    admin_email "tom@example.com"
    time_zone 'Eastern Time (US & Canada)'
  end
end
