class Schedule < ActiveRecord::Base
	validates_uniqueness_of :event, :scope => [:tournament_id, :division], :message => "This event already exists at this Tournament and Division"
	validates_presence_of :event, :tournament, :division

	has_many :timeslots
	belongs_to :tournament
	# TODO: Validate start, end, and timeslots.
	

	def updateTimeSlots()
		# Currently, the only supported schedule type is even divisions of time... e.g.
		#  StartTime = 9am, EndTime = 10am, timeslots = 4
		#  9:00am, 9:15am, 9:30am, 9:45am
		#
		#  Return an array of all event timeslots by their database id... e.g.
		if self.starttime.nil?
			return "Error: No scheduled start time"
		end
		if self.endtime.nil?
			return "Error: No scheduled end time"
		end
		if self.num_timeslots.nil?
			return "Error: No defined amount of divisions"
		end
		minutes = (( self.endtime - self.starttime ) / 60 ).round
		slotwidth = (minutes / self.num_timeslots).floor
		if slotwidth == 0
			return "Error: Timeslots too narrow"
		end
		existing_timeslots = self.timeslots
		new_timeslots = []
		self.num_timeslots.times do |i|
			begintime = self.starttime + slotwidth*60*i
			# Warning: Long method name ahead!
			exists = Timeslot.find_or_create_by_schedule_id_and_begins_and_ends_and_team_capacity(:schedule_id => self.id, :begins => begintime, :ends => begintime + slotwidth*60, :team_capacity => self.teams_per_slot)
			new_timeslots.push(exists)
		end
		existing_timeslots.each do |t|
			if not new_timeslots.include?(t)
				t.delete()
			end
		end
		return new_timeslots
	end
	def self.isValidTimeSlot(schedule, time)
		return schedule.getTimeSlots().include?(time)
	end
	def hasTeamRegistered(team_id)
		signups = SignUp.find(:first, :conditions => ["timeslot_id in (select id from timeslots where schedule_id = ?) and team_id = ?", self, team_id])
		if signups.nil?
			return false
		end
		return true
	end
end
