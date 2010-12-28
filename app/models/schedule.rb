class Schedule < ActiveRecord::Base
	validates_uniqueness_of :event, :scope => [:tournament, :division], :message => "This event already exists at this Tournament and Division"
	validates_presence_of :event, :tournament, :division

	has_many :sign_ups
	# TODO: Validate start, end, and timeslots.
	

	def getTimeSlots()
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
		if self.timeslots.nil?
			return "Error: No defined amount of divisions"
		end
		minutes = (( self.endtime - self.starttime ) / 60 ).round
		slotwidth = (minutes / self.timeslots).floor
		timeslots = []
		self.timeslots.times do |i|
			timeslots.push(self.starttime + slotwidth*60*i)
#			timeslots.push(Schedule.getTimeSlotID(self.tournament, self.id, self.starttime + slotwidth*60*(i)))
		end
		return timeslots
	end
	def self.isValidTimeSlot(schedule, time)
		return schedule.getTimeSlots().include?(time)
	end
# 	I'm not sure what I was thinking while making this hash function for TimeSlot IDs.
#
#	def self.getTimeSlotID(tournamentid, scheduleid, time)
#		strtime = time.strftime("%H%M").to_s
#		return tournamentid.to_s + "=" + scheduleid.to_s + "=" + strtime
#	end
end
