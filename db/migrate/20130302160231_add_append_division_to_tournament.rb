class AddAppendDivisionToTournament < ActiveRecord::Migration
  def change
    change_table :tournaments do |t|
      t.boolean :append_division_to_team_number, :default => 1
    end
  end
end
