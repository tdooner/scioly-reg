class Schedule < ActiveRecord::Base
  validates_presence_of :event, :division, :starttime, :endtime
  attr_accessor :num_timeslots, :teams_per_slot

  has_many :timeslots
  has_many :scores
  belongs_to :tournament
  # TODO: Validate start, end, and timeslots.


  def updateTimeSlots
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
    teams_per_slot = 1 if teams_per_slot.nil?
    minutes = (( self.endtime - self.starttime ) / 60 ).round
    slotwidth = (minutes / self.num_timeslots.to_i).floor
    if slotwidth <= 0
      return "Error: Timeslots too narrow"
    end
    existing_timeslots = self.timeslots
    new_timeslots = []

    # Find any timeslots that serendipitously remained the same if num_timeslots
    # has been changed.
    self.num_timeslots.to_i.times do |i|
      begintime = self.starttime + slotwidth * 60 * i
      # TODO: Upgrade to ActiveRecord 3.2.1 and destroy this long method name:
      exists = Timeslot.find_or_create_by_schedule_id_and_begins_and_ends_and_team_capacity(
        :schedule_id => self.id,
        :begins => begintime,
        :ends => begintime + slotwidth * 60,
        :team_capacity => self.teams_per_slot
      )
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
  def humanize
    "#{self.event} (#{self.division})"
  end
  def is_scheduled_online?
    not self.timeslots.empty?
  end
end
