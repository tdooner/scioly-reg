class Schedule < ActiveRecord::Base
  validates_presence_of :event, :division
  validates_uniqueness_of :event, :scope => [:division, :tournament_id]

  attr_accessor :num_timeslots, :teams_per_slot

  has_many :timeslots
  has_many :scores
  belongs_to :tournament


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
    if self.num_timeslots.to_i <= 0
      return "Error: No defined amount of divisions"
    end
    minutes = (( self.endtime - self.starttime ) / 60 ).round
    slotwidth = (minutes / self.num_timeslots.to_i).floor
    if slotwidth <= 0
      return "Error: Timeslots too narrow"
    end

    existing_timeslots = self.timeslots.reload
    new_timeslots = _initialize_timeslots(self.num_timeslots.to_i, self.teams_per_slot)

    existing_timeslots.each do |t|
      if !new_timeslots.include?(t)
        t.delete
      end
    end

    new_timeslots.map(&:save)

    return timeslots.reload
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

  def times
    @times ||= {
      :start => (starttime && starttime.strftime("%l:%M %P")) || 'TBD',
      :start_excel => (starttime && starttime.strftime("%T")) || 'TBD',
      :end => (endtime && endtime.strftime("%l:%M %P")) || 'TBD',
      :end_excel => (endtime && endtime.strftime("%T")) || 'TBD',
    }
  end

  def is_scheduled_online?
    not self.timeslots.empty?
  end

  # False if the user has made any customizations to any of the timeslots
  # else True
  def default_timeslots?
    true if self.timeslots.count == 0

    _initialize_timeslots(self.timeslots.count, self.timeslots.first.team_capacity).all?(&:persisted?) &&
    (!num_timeslots || self.timeslots.count == num_timeslots.to_i)
  end

  private

  def _initialize_timeslots(num_timeslots, teams_per_slot)
    return [] unless self.endtime && self.starttime
    return [] unless num_timeslots > 0
    teams_per_slot ||= 1

    minutes = (( self.endtime - self.starttime ) / 60 ).round
    slotwidth = (minutes / num_timeslots).floor

    num_timeslots.times.map do |i|
      timeslot_begins = self.starttime + slotwidth * 60 * i
      timeslot_ends = timeslot_begins + slotwidth * 60
      exists = Timeslot.where(
        :schedule_id => self.id,
        :begins => timeslot_begins,
        :ends => timeslot_ends,
        :team_capacity => teams_per_slot,
      ).first_or_initialize
    end
  end
end
