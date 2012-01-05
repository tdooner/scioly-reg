class AddScoresRevealedToTournament < ActiveRecord::Migration
  def self.up
    add_column :tournaments, :scores_revealed, :boolean, :default=>:false
  end

  def self.down
    remove_column :tournaments, :scores_revealed
  end
end
