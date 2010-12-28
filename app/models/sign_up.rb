class SignUp < ActiveRecord::Base
	belongs_to :team
    belongs_to :schedule

	validates_uniqueness_of :team_id, :scope => [:schedule_id, :time]

	def self.getSignUps(scheduleid)
		signups = Schedule.find(scheduleid).sign_ups
		signarray = {}
		signups.each do |s|
			signarray[s.time] = s
		end # signups.map { |s| signarray[s.time] = s }
		return signarray
	end
end
