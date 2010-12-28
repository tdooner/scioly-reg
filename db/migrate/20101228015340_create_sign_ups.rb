class CreateSignUps < ActiveRecord::Migration
  def self.up
    create_table :sign_ups do |t|
	  t.integer :scheduleid
	  t.integer :teamid
	  t.time :time
      t.timestamps
    end
  end

  def self.down
    drop_table :sign_ups
  end
end
