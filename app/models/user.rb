class User < ActiveRecord::Base
  belongs_to :school
  validates_confirmation_of :password
  validates_presence_of :email, :school_id
  validates_uniqueness_of :email, :scope => [:school_id]
  attr_accessor :password, :password_confirmation

	def is_admin_of(school)
      return false if school.nil?
      return (self.role == 1 && self.school_id == school.id)
	end

    def password=(p)
      @password = p
      self.hashed_password = Digest::SHA1.hexdigest(p)
    end

    def self.authenticate(school, email, password)
      #TODO: Salt this.
      u = User.find_by_school_id_and_email(school.id, email)
      return nil unless u

      if u.hashed_password == Digest::SHA1.hexdigest(password)
        return u
      else
        return nil
      end

    end
end
