class AddDontPublishScheduleScores < ActiveRecord::Migration
  def self.up
    add_column :schedules, :scores_withheld, :boolean, :default => :false
  end

  def self.down
    remove_column :schedules, :scores_withheld
  end
end
