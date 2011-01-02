class SignUp < ActiveRecord::Base
	belongs_to :team
    belongs_to :schedule

	validates_presence_of :team_id, :schedule_id, :time
	validates_uniqueness_of :team_id, :scope => [:schedule_id], :message => "has already registered for this event!"

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
		# Get the list of all schedules...
		schedules = Schedule.find(:all, :conditions => ["tournament_id = ?", Tournament.get_current().id])
		# ...and run it against that team's registrations.
		# TODO: Figure out the appropriate join for this query to avoid this loop.
		unregistered = []
		schedules.each do |s|
			if not SignUp.find(:first, :conditions => ["schedule_id = ? AND team_id = ?", s.id, team.id])
				unregistered.push(s)
			end
		end
		return unregistered
	end

	# Called whenever a new SignUp is saved
	def validate
		if not isEmpty(self.time)
			errors.add(:time, "is already occupied.")
		end
		if not Schedule.isValidTimeSlot(self.schedule, self.time)
			errors.add(:time, "is not a valid timeslot.")
		end
	end

	def isEmpty(time)
		return SignUp.isEmpty(self.schedule, time)
	end
	def self.isEmpty(schedule, time)
		return !SignUp.getSignUps(schedule).key?(time)
	end
end
