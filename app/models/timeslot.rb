class Timeslot < ActiveRecord::Base
  belongs_to :schedule
  has_many :sign_ups
  has_many :occupants, :through => :sign_ups, :source => 'team'
end
