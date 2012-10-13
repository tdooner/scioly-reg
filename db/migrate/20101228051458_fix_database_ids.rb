class FixDatabaseIds < ActiveRecord::Migration
  def self.up
      rename_column(:schedules,:tournament, :tournament_id)

      rename_column(:sign_ups,:scheduleid, :schedule_id)
      rename_column(:sign_ups,:teamid, :team_id)

      rename_column(:teams,:tournamentid, :tournament_id)
  end

  def self.down
      rename_column(:schedules,:tournament_id, :tournament)

      rename_column(:sign_ups,:schedule_id, :scheduleid)
      rename_column(:sign_ups,:team_id, :teamid)

      rename_column(:teams,:tournament_id, :tournamentid)
  end
end
