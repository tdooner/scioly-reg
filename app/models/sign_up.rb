class SignUp < ActiveRecord::Base
  belongs_to :team
  belongs_to :timeslot

  validates_presence_of :team_id, :timeslot_id
  validate :custom_validate

  def self.getSignUps(scheduleid)
    signups = Schedule.find(scheduleid).sign_ups
    signarray = {}
    signups.each do |s|
      signarray[s.time] = s
    end # signups.map { |s| signarray[s.time] = s }
    return signarray
  end

  # Called whenever a new SignUp is saved
  def custom_validate
    t = self.team.tournament
    if self.timeslot.schedule.tournament != t
      errors[:base] << "This event is not available in the current tournament."
    end
    if self.team.division != self.timeslot.schedule.division
      errors[:base] << "This event is not your current division."
    end
    if !t.has_registration_begun?
      errors[:base] << "Registration for this tournament begins at " + t.human_times[:registration_begins]
    end
    if t.has_registration_ended?
      errors[:base] << "Registration for this tournament ended at " + t.human_times[:registration_ends]
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
