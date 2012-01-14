class CreateSchools < ActiveRecord::Migration
  def self.up
    create_table :schools do |t|
      t.string :name
      t.string :subdomain
      t.has_attached_file :homepage_photo
      t.string :admin_name
      t.string :admin_email
      t.string :admin_password

      t.timestamps
    end

    add_index :schools, :subdomain
  end

  def self.down
    drop_table :schools
  end
end
