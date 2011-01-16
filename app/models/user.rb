class User < ActiveRecord::Base
	def self.is_admin(user)
		return (user.role == 1)
	end
end
