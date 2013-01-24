class AddEmailToTeam < ActiveRecord::Migration
  def change
    change_table :teams do |t|
      t.string :email
    end
  end
end
