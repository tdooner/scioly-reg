class AddRoomToSchedules < ActiveRecord::Migration
  def self.up
	  add_column :schedules, :room, :string
  end

  def self.down
	  remove_column :schedules, :room
  end
end
