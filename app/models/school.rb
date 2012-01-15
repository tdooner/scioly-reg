require 'digest/sha1'

class School < ActiveRecord::Base
  has_attached_file :logo, :styles => {:medium => "200x200", :logo=>"220x75", :slideshow=>"163x180" }

  validates_presence_of :name, :subdomain, :admin_name, :admin_email

  has_many :tournaments
  has_many :users

end
