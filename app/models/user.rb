class User < ActiveRecord::Base
  validates_presence_of :email, :hashed_password
  validates_uniqueness_of :email

  validates_confirmation_of :password
  attr_accessor :password, :password_confirmation

  has_many :administrations
  has_many :administered_schools, through: :administrations,
    source: :administrates, source_type: 'School'
  has_many :administered_teams, through: :administrations,
    source: :administrates, source_type: 'Team'

  def administers?(obj)
    case obj
    when School
      administered_schools.include?(obj)
    when Team
      administered_teams.include?(obj)
    else
      false
    end
  end

  def password=(p)
    @password = p
    self.hashed_password = Digest::SHA1.hexdigest(p)
  end

  def self.authenticate(email, password)
    # TODO: Salt this.

    u = User.find_by(email: email)

    if u && u.hashed_password == Digest::SHA1.hexdigest(password)
      return u
    end
  end

  def can_delete?(u)
    return false unless u.is_a?(User)
    return false if u.school.admin_email == u.email
    return self.administers?(self.school) && u.school == self.school
  end

  def can_edit?(obj)
    case obj
    when Schedule
      administers?(obj.tournament.school)
    when Tournament
      administers?(obj.school)
    when Team
      administers?(obj.tournament.school)
    else
      false
    end
  end

  def can_view?(obj)
    case obj
    when Schedule
      administers?(obj.tournament.school)
    else
      false
    end
  end

  def can_register_team_for_event?(team, obj)
    return false unless obj.is_a?(Schedule)
    return false unless team.is_a?(Team)
    return false unless team.division == obj.division
    return administers?(obj.tournament.school)
  end
end
