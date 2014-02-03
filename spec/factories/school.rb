FactoryGirl.define do
  factory :school do
    sequence(:name) {|x| "Nordonia High School #{x}"}
    sequence(:subdomain) { |x| ('a'..'z').to_a.sample(10).join }
    admin_name "Tom"
    admin_email "tom@example.com"
  end
end
