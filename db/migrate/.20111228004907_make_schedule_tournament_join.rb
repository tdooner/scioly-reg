class MakeScheduleTournamentJoin < ActiveRecord::Migration
  def self.up
    create_table :schedules_tournaments, :id => false do |t|
      t.integer :tournament_id
      t.integer :schedule_id
    end
    Schedule.all.each do |s|
      execute "INSERT INTO schedules_tournaments (tournament_id, schedule_id) VALUES(#{s.tournament_id}, #{s.id})"
    end
    remove_column :schedules, :tournament_id
  end

  def self.down
    add_column :schedules, :tournament_id, :integer
    Schedule.all.each do |s|
      execute("UPDATE schedules SET tournament_id=#{s.tournaments.last.id} WHERE id=#{s.id}") if s.tournaments.last
    end
    drop_table :schedules_tournaments
  end
end
