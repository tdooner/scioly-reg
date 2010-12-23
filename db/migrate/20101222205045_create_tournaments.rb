class CreateTournaments < ActiveRecord::Migration
  def self.up
    create_table :tournaments do |t|
      t.date :date
      t.boolean :isCurrent
      t.datetime :registrationBegins
      t.datetime :registrationEnds

      t.timestamps
    end
  end

  def self.down
    drop_table :tournaments
  end
end
