class Tournament < ActiveRecord::Base
  VALID_DIVISIONS = /[A-Z]/

  has_many :teams
  has_many :schedules
  has_attached_file :homepage_photo,
    :styles => {:medium => "181x200", :slideshow => "163x180" },
    :default_url => '/assets/sciolylogo_transparent.png'
  alias_attribute :current?, :is_current

  belongs_to :school

  validates_presence_of :date, :school_id

  def set_current
    return if current?

    transaction do
      school.tournaments.update_all(is_current: false)
      update_attributes(is_current: true)
    end
  end

  def humanize()
    return date.strftime("%B %d, %Y")
  end

  def human_times()
    format1 = "%B %e, %Y @ %I:%M %p %Z"
    {
      :registration_begins => self.registration_begins.strftime(format1),
      :registration_ends => self.registration_ends.strftime(format1),
      :date_filename => date.strftime("%F"),
    }
  end

  def divisions
    @divisions ||=
      schedules.map(&:division).find_all { |d| d =~ VALID_DIVISIONS }.uniq.sort
  end

  def has_registration_begun?
    self.registration_begins < Time.zone.now
  end

  def has_registration_ended?
    self.registration_ends < Time.zone.now
  end

  def can_register?
    self.has_registration_begun? && !self.has_registration_ended?
  end

  def show_scores?
    fake_time = Time.now + Time.now.gmt_offset
    release_time = self.date + 20.hours
    # If the time is before the default release and the admins haven't shown scores, don't display them.
    return false if (!self.scores_revealed && fake_time < release_time)
    # Otherwise, either the time has passed or the 'Reveal Scores' button has been pressed, so
    #  don't release any scores if an event is being withheld.
    return false unless self.schedules.select{|x| x.scores_withheld}.empty?
    # Otherwise, things are looking good!
    return true
  end

  def load_default_events(year = date.year)
    DefaultEvent.for_year(year).each do |e|
      self.schedules.where(:event => e.name, :division => e.division).
        first_or_create(:room => 'TBD')
    end
  end
end
