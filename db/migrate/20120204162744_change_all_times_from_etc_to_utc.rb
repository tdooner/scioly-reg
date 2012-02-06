class ChangeAllTimesFromEtcToUtc < ActiveRecord::Migration
  def self.up
    offset = ActiveSupport::TimeZone.new("EST").utc_offset
    Timeslot.all.each do |t|
      t.update_attribute(:begins, t.begins - offset)
      t.update_attribute(:ends, t.begins - offset)
    end
    Schedule.all.each do |s|
      s.update_attribute(:starttime, s.starttime - offset)
      s.update_attribute(:endtime, s.endtime - offset)
    end
    Tournament.all.each do |t|
      t.update_attribute(:registration_begins, t.registration_begins - offset)
      t.update_attribute(:registration_ends, t.registration_ends - offset)
    end
  end

  def self.down
    offset = ActiveSupport::TimeZone.new("EST").utc_offset
    Timeslot.all.each do |t|
      t.update_attribute(:begins, t.begins + offset)
      t.update_attribute(:ends, t.begins + offset)
    end
    Schedule.all.each do |s|
      s.update_attribute(:starttime, s.starttime + offset)
      s.update_attribute(:endtime, s.endtime + offset)
    end
    Tournament.all.each do |t|
      t.update_attribute(:registration_begins, t.registration_begins + offset)
      t.update_attribute(:registration_ends, t.registration_ends + offset)
    end
  end
end
