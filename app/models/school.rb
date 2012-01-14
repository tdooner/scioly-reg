require 'digest/sha1'

class School < ActiveRecord::Base
  has_attached_file :logo, :styles => {:medium => "200x200", :logo=>"220x75"}

  validates_presence_of :name, :subdomain, :admin_name, :admin_email, :admin_password
  validates_confirmation_of :password, :password_confirm

  attr_accessor :password, :password_confirm, :existing_password

  has_many :tournaments

  def password=(v)
    self.admin_password = Digest::SHA1.hexdigest(v)
  end
end
