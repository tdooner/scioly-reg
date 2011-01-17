class LowercaseColumnsForHeroku < ActiveRecord::Migration
  def self.up
	  rename_column :tournaments, :isCurrent, :is_current
	  rename_column :tournaments, :registrationBegins, :registration_begins
	  rename_column :tournaments, :registrationEnds, :registration_ends
  end

  def self.down
	  rename_column :tournaments, :is_current, :isCurrent
	  rename_column :tournaments, :registration_begins, :registrationBegins
	  rename_column :tournaments, :registration_ends, :registrationEnds
  end
end
