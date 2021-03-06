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
      return false if u.school.admin_email == u.email
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

    def can_view?(obj)
      if obj.is_a?(Schedule)
        return (self.is_admin_of(self.school) && self.school == obj.tournament.school)
      end
    end

    def can_register_team_for_event?(team, obj)
      return false unless obj.is_a?(Schedule)
      return false unless team.is_a?(Team)
      return false unless team.division == obj.division
      return (self.is_admin_of(obj.tournament.school))
    end
end
