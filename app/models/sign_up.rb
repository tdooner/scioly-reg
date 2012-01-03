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
		Tournament.get_current.schedules.find(:all, :conditions => ["division = ? and id not in (SELECT schedule_id FROM timeslots WHERE id in (SELECT timeslot_id from sign_ups WHERE team_id=?))", team.division ,team.id])
	end

	# Called whenever a new SignUp is saved
	def validate
      t = Tournament.get_current
      if not self.timeslot.schedule.tournaments.include?(t)
        errors.add_to_base("This event is not available in the current tournament.")
      end
		if not t.has_registration_begun()
			errors.add_to_base("Registration for this tournament begins at " + t.registration_begins.strftime("%B %d, %Y at %I:%M %p"))
		end
		if t.has_registration_ended()
			errors.add_to_base("Registration for this tournament ended at " + t.registration_ends.to_s)
		end
		if self.timeslot.schedule.hasTeamRegistered(team_id)
			errors.add(:team_id, "is already registered for this event!")
		end
		other_teams = self.timeslot.occupants
		# If there is not an empty spot and the current team does not already
		#  possess a spot in this event. (SignUps could potentially be edited
		#  and then validation should not fail simply because the timeslot has
		#  since filled up)
		if not other_teams.length < self.timeslot.team_capacity and not other_teams.include?(self.team)
			errors.add(:timeslot_id, "is full!")
		end
	end

	def isEmpty(time)
		return SignUp.isEmpty(self.schedule, time)
	end
	def self.isEmpty(schedule, time)
		return !SignUp.getSignUps(schedule).key?(time)
	end
end
