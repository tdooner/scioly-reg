class ChangeScheduleStartAndEndTimesToTimes < ActiveRecord::Migration
  def up
    change_column :schedules, :starttime, :time
    change_column :schedules, :endtime, :time
  end

  def down
    change_column :schedules, :starttime, :datetime
    change_column :schedules, :endtime, :datetime
  end
end
