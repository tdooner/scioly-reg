class RenameTimeslotsToNotConflict < ActiveRecord::Migration
  def self.up
	  rename_column :schedules, :timeslots, :num_timeslots
  end

  def self.down
	  rename_column :schedules, :num_timeslots, :timeslots
  end
end
