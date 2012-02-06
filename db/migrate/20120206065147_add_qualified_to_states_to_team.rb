class AddQualifiedToStatesToTeam < ActiveRecord::Migration
  def self.up
    add_column :teams, :qualified_for_states, :boolean, :default => false
  end

  def self.down
    remove_column :teams, :qualified_for_states
  end
end
