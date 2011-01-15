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
		if session[:loginattempts].nil?
			session[:loginattempts] = 0
			session[:showedcaptcha] = false
		end
		@captcha = false
		if session[:loginattempts] > 3
			@captcha = true
		end
		
		@teams = Team.find(:all, :conditions => ["division = ?", @division])
		if not session[:team].nil?
			flash[:message] = "Already logged in!"
		end
		if request.post?
			if @captcha == true and session[:showedcaptcha] == true
				if not verify_recaptcha()
					flash[:message] = "Incorrect reCAPTCHA"
					return
				end
			end
			session[:loginattempts] += 1
			if session[:team] = Team.authenticate(params[:team][:id], params[:password])
				flash[:message] = "Logged in!"
				session[:loginattempts] = nil
				redirect_to :root
			else
				flash[:message] = "Not Logged In!"
			end
		end

		if @captcha == true
			session[:showedcaptcha] = true
		end
	end
	def logout
		session[:team] = nil
		redirect_to root_url
	end
end
