class CreateInfos < ActiveRecord::Migration
  def self.up
    create_table :infos do |t|
        t.string :name
        t.text :page_text
        t.binary :contents

      t.timestamps
    end
  end

  def self.down
    drop_table :infos
  end
end
