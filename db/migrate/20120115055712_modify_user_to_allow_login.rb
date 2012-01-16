class ModifyUserToAllowLogin < ActiveRecord::Migration
  def self.up
    remove_column :users, :case_id
    add_column :users, :email, :string
    add_column :users, :password, :string
  end

  def self.down
    remove_column :users, :email
    remove_column :users, :password
    add_column :users, :case_id, :string, :default=>""
  end
end
