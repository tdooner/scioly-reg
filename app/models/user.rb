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

    def can_delete?(u)
      return false unless u.is_a?(User)
      return false if self.school.admin_email == self.email
      return self.is_admin_of(self.school) && u.school == self.school
    end

    def can_edit?(obj)
      if obj.is_a?(Schedule)
        return (self.is_admin_of(self.school) && self.school == obj.tournament.school)
      end
      if obj.is_a?(Tournament)
        return (self.is_admin_of(obj.school))
      end
      if obj.is_a?(Team)
        return self.is_admin_of(obj.tournament.school)
      end
    end
end
