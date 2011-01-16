class AddUsersTable < ActiveRecord::Migration
  def self.up
	  create_table :users do |t|
		  t.string :caseId
		  t.integer :role, :default => 0
	  end
  end

  def self.down
	  drop_table :users
  end
end
