class SignUp < ActiveRecord::Base
	belongs_to :team
    belongs_to :timeslot

	validates_presence_of :team_id, :timeslot_id

	def self.getSignUps(scheduleid)
		signups = Schedule.find(scheduleid).sign_ups
		signarray = {}
		signups.each do |s|
			signarray[s.time] = s
		end # signups.map { |s| signarray[s.time] = s }
		return signarray
	end

	# Returns list of all schedules that given team still needs to register for.
	def self.getTeamUnregistered(team)
		Schedule.find(:all, :conditions => ["id not in (SELECT schedule_id FROM timeslots WHERE id in (SELECT timeslot_id from sign_ups WHERE team_id=?))", team.id])
	end

	# Called whenever a new SignUp is saved
	def validate
		if self.timeslot.schedule.hasTeamRegistered(team_id)
			errors.add(:team_id, "is already registered for this event!")
		end
	end

	def isEmpty(time)
		return SignUp.isEmpty(self.schedule, time)
	end
	def self.isEmpty(schedule, time)
		return !SignUp.getSignUps(schedule).key?(time)
	end
end
