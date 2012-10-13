class MakePasswordAHash < ActiveRecord::Migration
  def self.up
     rename_column(:teams, :password, :hashed_password)
  end

  def self.down
      rename_column(:teams, :hashed_password, :password)
  end
end
