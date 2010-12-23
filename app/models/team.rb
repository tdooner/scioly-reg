require 'digest/sha1'

class Team < ActiveRecord::Base
	validates_presence_of :password # Validate this further???
	validates_presence_of :number
	validates_presence_of :tournamentid
	validates_presence_of :division
	validates_uniqueness_of :number, :scope => :tournamentid
#	validates_confirmation_of :password # if we want to confirm a password with a password_confirmation method

	belongs_to :tournament
	attr_accessor :password


	@@divisions = {"B" => "B", "C" => "C"}
	
	def self.authenticate(id, password)
		u = find(:first, :conditions=>["id = ?", id])
		return nil if u.nil?
		return u if encrypt(password)==u.hashed_password
		nil
	end

	def self.encrypt(pass)
		return Digest::SHA1.hexdigest(pass)
	end

	def password=(pass) #Rails magic -- gets called whenever a password is assigned (u.password = "secret")
		@password = pass
		self.hashed_password = Team.encrypt(@password)
	end

	def self.divisions
		return @@divisions
	end
end
