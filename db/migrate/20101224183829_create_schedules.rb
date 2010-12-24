class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t|
      t.string :event
      t.integer :tournament
      t.string :division
      t.time :starttime
      t.time :endtime
      t.integer :timeslots

      t.timestamps
    end
  end

  def self.down
    drop_table :schedules
  end
end
