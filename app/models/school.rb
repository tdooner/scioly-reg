class School < ActiveRecord::Base
  has_attached_file :homepage_photo

  validates_presence_of :name, :subdomain, :admin_name, :admin_email, :admin_password

  has_many :tournaments

end
