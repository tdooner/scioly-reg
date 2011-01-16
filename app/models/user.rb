class User < ActiveRecord::Base
	def self.is_admin(user)
		if user.nil?
			return false
		end
		return (user.role == 1)
	end
	def is_admin()
		return self.role == 1
	end
end
