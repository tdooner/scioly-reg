class TeamsController < ApplicationController
	before_filter :is_admin, :only => [:new, :create]
	before_filter :is_correct_team, :only => [:edit, :update]

	def index
		@teams = @current_tournament.teams
		render :list
	end
	def list
		@teams = @current_tournament.teams
	end
	def edit
		@this_team = Team.find(params[:id])
		breadcrumbs.add("Edit Team #" + @this_team.getNumber())
	end
	def update
		### Ensure 
		@this_team = Team.find(params[:id])
		if params[:team][:password] != params[:team][:password_confirm]
			flash[:error] = "Passwords do not match!"
			redirect_to edit_team_url(params[:id])
			return
		end
		# If the user is not admin, ensure the existing password is correct...
		if session[:user].nil? or not session[:user].is_admin
			@this_team.password_existing = params[:team][:password_existing]
			if Team.encrypt(params[:team][:password_existing]) != @this_team.hashed_password
				flash[:error] = "Current password is incorrect!"
				redirect_to edit_team_url(params[:id])
				return
			end
		end

		if not session[:user].nil? and session[:user].is_admin
			if not @this_team.update_attributes(params[:team])
				flash[:error] = "A save error occurred: " + @this_team.errors.full_messages.first + "."
			end
			redirect_to edit_team_url(params[:id])
		else
			if @this_team.update_attributes({:password => params[:team][:password], :password_confirm => params[:team][:password_confirm]})
				@div = @team.division
				@team = nil
				redirect_to login_url(@div)
			else
				flash[:error] = "A save error occurred: " + @this_team.errors.full_messages.first + "."
				redirect_to edit_team_url(params[:id])
			end
		end
	end
	def new
		@this_team = Team.new
	end
	def create
		@this_team = Team.new(params[:team])
		@this_team.tournament = Tournament.get_current()
		if @this_team.save
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
		
		@teams = Team.find_all_by_tournament_id_and_division(@current_tournament, params[:division]).sort
		if @team
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
				return redirect_to :root
			else
				# If the user is logged in as an admin
				if not session[:user].nil? and session[:user].is_admin()
					session[:team] = Team.find(params[:team][:id]).id
					session[:loginattempts] = nil
					return redirect_to :root
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
		if @team.id != params[:id].to_i
			redirect_to edit_team_url(session[:team])
			return
		end		
	end
end
