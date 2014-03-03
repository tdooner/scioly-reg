class AddSlugToSchedule < ActiveRecord::Migration
  def up
    change_table :schedules do |t|
      t.string :slug
    end

    Schedule.find_each do |s|
      s.send(:update_slug)
      s.save
    end
  end

  def down
    remove_column :schedules, :slug
  end
end
