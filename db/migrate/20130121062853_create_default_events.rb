class CreateDefaultEvents < ActiveRecord::Migration
  def up
    create_table :default_events do |t|
      t.integer :year     # the year of the national tournament for that season
      t.string :name
      t.string :division

      t.timestamps
    end
  end

  def down
    drop_table :default_events
  end
end
