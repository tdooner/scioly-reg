class RemovePasswordFromSchool < ActiveRecord::Migration
  def self.up
    remove_column :schools, :admin_password
  end

  def self.down
    add_column :schools, :admin_password, :string
  end
end
