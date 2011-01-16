class FixColumnName < ActiveRecord::Migration
  def self.up
	  rename_column :users, :caseId, :case_id
  end

  def self.down
	  rename_column :users, :case_id, :caseId
  end
end
