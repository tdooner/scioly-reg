class AddDivisionsToTournament < ActiveRecord::Migration
  def up
    change_table :tournaments do |t|
      t.string :divisions
    end

    Tournament.all.each do |tournament|
      tournament.divisions = tournament.schedules.pluck(:division).uniq || []
      tournament.save
    end
  end

  def down
    remove_column :tournaments, :divisions
  end
end
