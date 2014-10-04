class AddPasswordResetFieldsToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.datetime :reset_token_sent_at
      t.string :reset_token
    end
  end
end
