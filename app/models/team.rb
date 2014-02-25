require 'digest/sha1'

class Team < ActiveRecord::Base
  validates_length_of :password, :minimum => 5, :if => :password_validation_required?
  validates_presence_of :number
  validates_presence_of :tournament_id
  validates_presence_of :division
  validates_uniqueness_of :number, :scope => [:tournament_id, :division]
  validates_uniqueness_of :name, :scope => [:tournament_id, :division]
  validates_confirmation_of :password, :if => :password_validation_required?

  belongs_to :tournament
  has_many :sign_ups, dependent: :destroy
  has_many :scores
  attr_accessor :password, :password_confirmation, :password_existing

  @@divisions = {"B" => "B", "C" => "C"}

  def getNumber()
    return number if !tournament.append_division_to_team_number
    return [number, division].join
  end

  def self.authenticate(id, password)
    u = find(id) rescue nil
    return nil if u.nil?
    return u if encrypt(password)==u.hashed_password
    nil
  end

  def self.encrypt(pass)
    return Digest::SHA1.hexdigest(pass)
  end

  def password=(pass)
    @password = pass
    self.hashed_password = Team.encrypt(@password)
  end

  def password_validation_required?
    !!self.password
  end

  def self.divisions
    return @@divisions
  end

  def rank_matrix
    # Something like [98, -1, -3, -4, -2, 0, ... ] to sort teams on.
    # 98 is total points
    # 1 is number of first places, etc., negative because we're sorting in increasing order
    places = scores.map(&:placement).group_by(&:abs).reduce({}){|a,i| a.merge({i[0] => -i[1].length})}
    num_teams = tournament.teams.select{|x| x.division == division}.length
    total_points = places.map{|k,v| k*v}.sum

    [total_points.abs] + (num_teams+1).times.map{|x| places[x+1] || 0}
  end

  # Returns list of all schedules that this team still needs to register for using set subtraction.
  def unregistered_events
    tournament
      .schedules
      .keep_if { |s| s.is_scheduled_online? && s.division == division } -
    sign_ups.map{|x| x.try(:timeslot).try(:schedule) }
  end

  def can_register_for_event?(s)
    s.division == self.division && s.tournament == self.tournament
  end
end
