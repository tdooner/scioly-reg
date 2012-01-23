class AddCustomInfoToSchedule < ActiveRecord::Migration
  def self.up
    add_column :schedules, :custom_info, :text, :default => ""
  end

  def self.down
    remove_column :schedules, :custom_info
  end
end
