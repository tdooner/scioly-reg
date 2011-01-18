class TeamsController < ApplicationController
	before_filter :is_admin, :only => [:new, :create]
	before_filter :is_correct_team, :only => [:edit, :update]

	def index
		@teams = Team.find(:all)
		render :list
	end
	def list
		@teams = Team.find(:all)
	end
	def edit
		@team = Team.find(params[:id])
		breadcrumbs.add("Edit Team #" + @team.getNumber())
	end
	def update
		### Ensure 
		@team = Team.find(params[:id])
		if params[:team][:password] != params[:team][:password_confirm]
			flash[:error] = "Passwords do not match!"
			redirect_to edit_team_url(params[:id])
			return
		end
		# If the user is not admin, ensure the existing password is correct...
		if session[:user].nil? or not session[:user].is_admin
			@team.password_existing = params[:team][:password_existing]
			if Team.encrypt(params[:team][:password_existing]) != @team.hashed_password
				flash[:error] = "Current password is incorrect!"
				redirect_to edit_team_url(params[:id])
				return
			end
		end

		if not session[:user].nil? and session[:user].is_admin
			if not @team.update_attributes(params[:team])
				flash[:error] = "A save error occurred: " + @team.errors.full_messages.first + "."
			end
			redirect_to edit_team_url(params[:id])
		else
			if @team.update_attributes({:password => params[:team][:password], :password_confirm => params[:team][:password_confirm]})
				@div = session[:team].division
				session[:team] = nil
				redirect_to login_url(@div)
			else
				flash[:error] = "A save error occurred: " + @team.errors.full_messages.first + "."
				redirect_to edit_team_url(params[:id])
			end
		end
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
		breadcrumbs.add "Division " + @division + " Login"
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
			flash[:error] = "Already logged in!"
		end
		if request.post?
			if @captcha == true and session[:showedcaptcha] == true
				if not verify_recaptcha()
					flash[:error] = "Incorrect Image Verification"
					return
				end
			end
			session[:loginattempts] += 1
			if params[:password].nil?
				params[:password] = ""
			end
			if session[:team] = Team.authenticate(params[:team][:id], params[:password])
				flash[:message] = "Logged in!"
				session[:loginattempts] = nil
				redirect_to :root
			else
				# If the user is logged in as an admin
				if not session[:user].nil? and session[:user].is_admin()
					session[:team] = Team.find(params[:team][:id])
					session[:loginattempts] = nil
					redirect_to :root
				end
				flash[:error] = "Incorrect Password For Selected Team"
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
	def is_correct_team
		# Checks if a team has the rights to perform this action.
		if not session[:user].nil? and session[:user].is_admin
			return
		end
		if session[:team][:id] != params[:id].to_i
			redirect_to edit_team_url(session[:team])
			return
		end		
	end
end
