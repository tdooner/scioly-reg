class RemoveNumTimeslotsAndTeamsPerSlot < ActiveRecord::Migration
  def self.up
    remove_column :schedules, :num_timeslots
    remove_column :schedules, :teams_per_slot
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
