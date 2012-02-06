class MakeEverythingDatetime < ActiveRecord::Migration
  def self.up
    rename_column :schedules, :starttime, :starttime_old
    add_column :schedules, :starttime, :datetime

    rename_column :schedules, :endtime, :endtime_old
    add_column :schedules, :endtime, :datetime

    Schedule.all.each{|x| x.update_attributes({:starttime => x.starttime_old, :endtime => x.endtime_old})}

    rename_column :tournaments, :date, :date_old
    add_column :tournaments, :date, :datetime
    Tournament.all.each{|x| x.update_attributes({:date => x.date_old})}

    remove_column :schedules, :starttime_old
    remove_column :schedules, :endtime_old
    remove_column :tournaments, :date_old
  end

  def self.down
    change_column :schedules, :starttime, :time
    change_column :schedules, :endtime, :time
    change_column :tournaments, :date, :date
  end
end
