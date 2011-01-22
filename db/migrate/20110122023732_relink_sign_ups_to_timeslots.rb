class RelinkSignUpsToTimeslots < ActiveRecord::Migration
  def self.up
	  rename_column :sign_ups, :schedule_id, :timeslot_id
  end

  def self.down
	  rename_column :sign_ups, :timeslot_id, :schedule_id
  end
end
