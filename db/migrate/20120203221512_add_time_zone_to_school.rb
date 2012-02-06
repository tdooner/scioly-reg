class AddTimeZoneToSchool < ActiveRecord::Migration
  def self.up
    add_column :schools, :time_zone, :string, :default => "Eastern Time (US & Canada)"
  end

  def self.down
    remove_column :schools, :time_zone
  end
end
