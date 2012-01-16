class AddTournamentToSchool < ActiveRecord::Migration
  def self.up
    add_column :tournaments, :school_id, :integer
  end

  def self.down
    remove_column :tournaments, :school_id
  end
end
