FactoryGirl.define do
  factory :sign_up, :aliases => [ :occupant ] do
    timeslot
    team
  end
end
