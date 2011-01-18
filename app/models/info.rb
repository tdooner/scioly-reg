class Info < ActiveRecord::Base
	def self.get_id(name)
		@idea = Info.find(:first, :conditions => ["name = ?", name])
		if not @idea.nil?
			return @idea.id
		else
			return 1
		end
	end
end
