class MakeEverythingDatetime < ActiveRecord::Migration
  def self.up
    change_column :schedules, :starttime, :datetime
    change_column :schedules, :endtime, :datetime
    change_column :tournaments, :date, :datetime
  end

  def self.down
    change_column :schedules, :starttime, :time
    change_column :schedules, :endtime, :time
    change_column :tournaments, :date, :date
  end
end
