class RemoveTimeFromSignUps < ActiveRecord::Migration
  def self.up
      remove_column :sign_ups, :time
  end

  def self.down
      raise ActiveRecord::IrreversibleMigration
  end
end
