class AddCountsForScoreToSchedules < ActiveRecord::Migration
  def self.up
    add_column :schedules, :counts_for_score, :boolean, :default => :true
  end

  def self.down
    remove_column :schedules, :counts_for_score
  end
end
