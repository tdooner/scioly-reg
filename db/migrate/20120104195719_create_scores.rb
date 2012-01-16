class CreateScores < ActiveRecord::Migration
  def self.up
    create_table :scores do |t|
      t.integer :schedule_id
      t.integer :team_id
      t.integer :placement

      t.timestamps
    end
  end

  def self.down
    drop_table :scores
  end
end
