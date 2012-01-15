class AddUserToSchool < ActiveRecord::Migration
  def self.up
    add_column :users, :school_id, :integer
  end

  def self.down
    remove_column :users, :school_id
  end
end
