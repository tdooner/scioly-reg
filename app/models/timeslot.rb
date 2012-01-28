class Timeslot < ActiveRecord::Base
  validates_presence_of :schedule_id, :begins, :ends, :team_capacity
	belongs_to :schedule
	has_many :sign_ups, :dependent => :destroy

	def occupants
		SignUp.where(:timeslot_id => self.id).map { |x| x.team }
	end

end
