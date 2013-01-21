class AddTimeZoneToSchools < ActiveRecord::Migration
  def change
    change_table :schools do |t|
      t.string :time_zone, :default => 'Eastern Time (US & Canada)'
    end
  end
end
