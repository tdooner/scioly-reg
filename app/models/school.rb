class School < ActiveRecord::Base
  has_attached_file :logo, :styles => { :medium => "200x200", :logo=>"220x75", :slideshow=>"163x180" }

  validates_presence_of :name, :subdomain
  validates_uniqueness_of :subdomain,
    :message => 'is used by another school',
    :case_sensitive => false

  has_many :tournaments, dependent: :destroy
  has_many :administrations, as: :administrates, dependent: :destroy
  has_many :administrators, through: :administrations,
    class_name: 'User', source: :user

  def url(domain = 'sciolyreg.org')
    "http://#{subdomain}.#{domain}"
  end
end
