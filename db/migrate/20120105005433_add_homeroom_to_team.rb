class AddHomeroomToTeam < ActiveRecord::Migration
  def self.up
    add_column :teams, :homeroom, :string
  end

  def self.down
    remove_column :teams, :homeroom
  end
end
