class SignUp < ActiveRecord::Base
	belongs_to :teamid
	validates_uniqueness_of :teamid, :scope => [:scheduleid, :time]

	def self.getSignUps(scheduleid)
		signups = SignUp.find(:all, :conditions => ["scheduleid = ?", scheduleid])
		signarray = {}
		signups.each do |s|
			signarray[s.time] = s
		end # signups.map { |s| signarray[s.time] = s }
		return signarray
	end
end
