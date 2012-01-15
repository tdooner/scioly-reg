# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :school do
    sequence(:name) {|x| "Nordonia High School #{x}"}
    subdomain "test"
    admin_name "Tom"
    admin_email "tom@example.com"
  end
end
