class AddHumanTitleToInfos < ActiveRecord::Migration
  def self.up
    add_column :infos, :human_name, :string
  end

  def self.down
      remove_column :infos, :human_name
  end
end
