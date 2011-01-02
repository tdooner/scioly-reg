class TeamsController < ApplicationController
	def index
		@teams = Team.find(:all)
		render :list
	end
	def list
		@teams = Team.find(:all)
	end
	def new
		@team = Team.new()
	end
	def create
		@team = Team.new(params[:team])
		@team.tournament = Tournament.get_current()
		if @team.save
			flash[:message] = "Done!"
		else
			flash[:message] = "Error!"
		end
		@teams = Team.find(:all)
		render :list
	end
	def login
		@division = params[:division] == "B"?"B":"C"
		@teams = Team.find(:all, :conditions => ["division = ?", @division])
		if not session[:team].nil?
			flash[:message] = "Already logged in!"
		end
		if request.post?
			if session[:team] = Team.authenticate(params[:team][:id], params[:password])
				flash[:message] = "Logged in!"
				redirect_to :root
			else
				flash[:message] = "Not Logged In!"
			end
		end
	end
	def logout
		session[:team] = nil
		redirect_to root_url
	end
end
