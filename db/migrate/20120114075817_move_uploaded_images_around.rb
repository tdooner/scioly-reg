class MoveUploadedImagesAround < ActiveRecord::Migration
  def self.up
    drop_attached_file :schools, :homepage_photo
    change_table :schools do |t|
      t.has_attached_file :logo
    end
    change_table :tournaments do |t|
      t.has_attached_file :homepage_photo
    end
  end

  def self.down
    drop_attached_file :schools, :logo
    drop_attached_file :tournaments, :homepage_photo
    change_table :schools do |t|
      has_attached_file :homepage_photo
    end
  end
end
