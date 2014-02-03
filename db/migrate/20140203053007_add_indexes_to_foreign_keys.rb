class AddIndexesToForeignKeys < ActiveRecord::Migration
  def change
    add_index :default_events, :year
    add_index :schedules, :tournament_id
    add_index :scores, :schedule_id
    add_index :scores, :team_id
    add_index :sign_ups, :timeslot_id
    add_index :sign_ups, :team_id
    add_index :teams, [:tournament_id, :division]
    add_index :timeslots, :schedule_id
    add_index :tournaments, [:school_id, :is_current]
    add_index :users, [:school_id, :email, :hashed_password]
  end
end
