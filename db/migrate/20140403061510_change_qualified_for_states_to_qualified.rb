class ChangeQualifiedForStatesToQualified < ActiveRecord::Migration
  def up
    rename_column :teams, :qualified_for_states, :qualified
  end

  def down
    rename_column :teams, :qualified, :qualified_for_states
  end
end
