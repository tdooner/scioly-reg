class ScoreValidator < ActiveModel::Validator
  def validate(record)
    return record.errors.add(:base, "Schedule cannot be empty") if record.schedule.nil?
    return record.errors.add(:base, "Placement cannot be empty") if record.placement.nil?
    max = record.schedule.tournament.teams.count+2
    record.errors.add(:base, "Placement error -- the largest ranking for this event is #{max}") if record.placement > (max)
  end
end

class Score < ActiveRecord::Base
  #include ActiveModel::ScoreValidator
  belongs_to :team
  belongs_to :schedule
  validates_presence_of :schedule_id, :team_id, :placement
  validates_uniqueness_of :team_id, :scope=>:schedule_id, :message=>"already has scores for this event!"
  validates_numericality_of :placement, :greater_than => 0
  validates_with ScoreValidator
end
