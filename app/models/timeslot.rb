class Timeslot < ActiveRecord::Base
  belongs_to :schedule
  has_many :sign_ups

  def occupants
    SignUp.where(:timeslot_id => self.id).map { |x| x.team }
  end
end
