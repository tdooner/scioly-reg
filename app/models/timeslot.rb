class Timeslot < ActiveRecord::Base
  belongs_to :schedule
  has_many :sign_ups, dependent: :destroy
  has_many :occupants, :through => :sign_ups, :source => 'team'

  validates :team_capacity, presence: true
end
