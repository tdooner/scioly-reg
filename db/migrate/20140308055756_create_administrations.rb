class CreateAdministrations < ActiveRecord::Migration
  def change
    create_table :administrations do |t|
      t.references :user
      t.integer :administrates_id
      t.string :administrates_type
    end
  end
end
