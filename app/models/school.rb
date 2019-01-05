require 'digest/sha1'

class School < ActiveRecord::Base
  has_attached_file :logo, :styles => { :medium => "200x200", :logo=>"220x75", :slideshow=>"163x180" }

  validates_presence_of :name, :subdomain, :admin_name, :admin_email
  validates_uniqueness_of :subdomain,
    :message => 'is used by another school',
    :case_sensitive => false
  validates_attachment_content_type :logo, content_type: %w[image/jpg image/jpeg image/png image/gif]

  has_many :tournaments
  has_many :users

  def url(domain = 'sciolyreg.org')
    "http://#{subdomain}.#{domain}"
  end
end
