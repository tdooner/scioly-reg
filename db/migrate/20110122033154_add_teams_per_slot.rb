class AddTeamsPerSlot < ActiveRecord::Migration
  def self.up
      add_column :schedules, :teams_per_slot, :integer, :default => 1
  end

  def self.down
      remove_column :schedules, :teams_per_slot
  end
end
