class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.string :name
      t.string :number
      t.string :division
      t.string :coach
      t.string :password

      t.timestamps
    end
  end

  def self.down
    drop_table :teams
  end
end
