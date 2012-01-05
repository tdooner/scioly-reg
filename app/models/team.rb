require 'digest/sha1'

class Team < ActiveRecord::Base
	validates_length_of :password,:minimum => 5, :if => :password_validation_required? # Validate this further???
	validates_presence_of :number
	validates_presence_of :tournament_id
	validates_presence_of :division
	validates_uniqueness_of :number, :scope => [:tournament_id, :division]
	validates_uniqueness_of :name, :scope => [:tournament_id, :division]
#	validates_confirmation_of :password # if we want to confirm a password with a password_confirmation method

	belongs_to :tournament
	has_many :sign_ups
    has_many :scores
	attr_accessor :password, :password_confirm, :password_existing


	@@divisions = {"B" => "B", "C" => "C"}
	
	# Returns 
	def getNumber()
		return [number, division].join
	end
	
	# Counterintuitively, self denotes a class (static) method.	
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
	def password_validation_required?
		return self.hashed_password.blank? || !self.password.blank? || !self.password_existing.blank?
	end

	def self.divisions
		return @@divisions
	end

	def <=>(team) #When this is compared to another team
		self.name <=> team.name
	end
end
