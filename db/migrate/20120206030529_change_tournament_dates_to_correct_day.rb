class ChangeTournamentDatesToCorrectDay < ActiveRecord::Migration
  def self.up
    offset = ActiveSupport::TimeZone.new("EST").utc_offset
    Tournament.all.each do |t|
      t.update_attribute(:date, t.date - offset) 
    end
  end

  def self.down
    offset = ActiveSupport::TimeZone.new("EST").utc_offset
    Tournament.all.each do |t|
      t.update_attribute(:date, t.date + offset) 
    end
  end
end
