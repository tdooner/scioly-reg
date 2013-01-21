FactoryGirl.define do
  factory :school do
    sequence(:name) {|x| "Nordonia High School #{x}"}
    sequence(:subdomain) { |x| "test-#{x}" }
    admin_name "Tom"
    admin_email "tom@example.com"
  end
end
