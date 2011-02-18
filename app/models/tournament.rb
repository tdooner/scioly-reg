class Tournament < ActiveRecord::Base
	has_many :teams

	def self.get_current()
		@t = find(:first, :conditions => ["is_current = ?", true])
		return @t if not @t.nil?
		nil
	end
	def set_current()
		Tournament.update_all("is_current='f'")
		self.update_attribute("is_current", true)
	end
	def humanize()
		return date.strftime("%B %d, %Y")
	end
	def human_times()
		format1 = "%B %e, %Y @ %I:%M %p"
		{:registration_begins => self.registration_begins.strftime(format1), :registration_ends => self.registration_ends.strftime(format1)}
	end
	def has_registration_begun()
		return self.registration_begins < Time.now
	end
	def has_registration_ended()
		return !(Time.now.utc + Time.zone_offset("EST") < self.registration_ends)
	end
	def can_register()
		return (self.has_registration_begun() and not self.has_registration_ended())
	end
end
