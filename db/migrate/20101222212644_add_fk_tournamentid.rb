class AddFkTournamentid < ActiveRecord::Migration
  def self.up
    add_column(:teams, :tournamentid, :integer)
  end

  def self.down
      remove_column(:teams, :tournamentid)
  end
end
