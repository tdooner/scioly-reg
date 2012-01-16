class Score < ActiveRecord::Base
  belongs_to :team
  belongs_to :schedule
  validates_uniqueness_of :team_id, :scope=>:schedule_id
  validates_numericality_of :placement

end
