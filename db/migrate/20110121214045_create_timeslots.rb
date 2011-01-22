class CreateTimeslots < ActiveRecord::Migration
  def self.up
    create_table :timeslots do |t|
      t.integer :schedule_id
      t.datetime :begins
      t.datetime :ends
      t.integer :team_capacity

      t.timestamps
    end
  end

  def self.down
    drop_table :timeslots
  end
end
