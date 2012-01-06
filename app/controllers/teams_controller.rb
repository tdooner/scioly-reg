class TeamsController < ApplicationController
	before_filter :is_admin, :only => [:new, :create, :batchnew]
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
            @mixpanel.track_event("Team Update", {:team => @this_team.name, :admin=>true, :failed => false})
			redirect_to edit_team_url(params[:id])
		else
			if @this_team.update_attributes({:password => params[:team][:password], :password_confirm => params[:team][:password_confirm]})
                @mixpanel.track_event("Team Update", {:team => @this_team.name, :admin=>false, :failed => false})
				@div = @team.division
				@team = nil
				redirect_to login_url(@div)
			else
				flash[:error] = "A save error occurred: " + @this_team.errors.full_messages.first + "."
                @mixpanel.track_event("Team Update", {:team => @this_team.name, :admin=>false, :failed => true})
				redirect_to edit_team_url(params[:id])
			end
		end
	end
	def new
        breadcrumbs.add("Create Team")
		@this_team = Team.new
	end
    def batchnew
        breadcrumbs.add("Create Team", new_team_url)
        breadcrumbs.add("Batch Mode")      
    end
    def batchcreate
      @teams = params[:batch].split("\n")
      @errors = []
      @teams.each do |t|
        a = t.split("\t")
        if a.length < 6
          @errors << "Short record found: #{a[0]}!"
          next
        end
        team = @current_tournament.teams.new({:name => a[0], :number => a[1], :coach => a[2], :division => a[3], :homeroom => a[4], :password => a[5].strip})
        if not team.save()
          @errors << "Error with #{a[0]}: #{team.errors.full_messages.first}"
        end
      end
      flash[:error] = @errors.join("<br />") unless @errors.empty?

      if not flash[:error]
        redirect_to teams_url
      else
        render :batchnew
      end
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
            if params[:is_admin] != "false"
              # Do it.
              flash[:message] = "<img src='http://i0.kym-cdn.com/photos/images/original/000/096/044/trollface.jpg?1296494117'>"
              @mixpanel.track_event("Changed is_admin", {:team_id => params[:team][:id], :ip => request.remote_ip})
              return redirect_to login_url(params[:division])
            end
			if team = Team.authenticate(params[:team][:id], params[:password])
                @mixpanel.track_event("Login", {:team => team.name, :admin=>"false", :failed => "false"})
                session[:team] = team.id
				flash[:message] = "Logged in!"
				session[:loginattempts] = nil
				return redirect_to :root
			else
				# If the user is logged in as an admin
				if not session[:user].nil? and session[:user].is_admin()
					team = Team.find(params[:team][:id])
                    @mixpanel.track_event("Login", {:team => team.name, :admin=>"true", :failed => "false"})
                    session[:team] = team.id
					session[:loginattempts] = nil
					return redirect_to :root
				end
                @mixpanel.track_event("Login", {:team => Team.find_by_id(params[:team][:id]).name, :admin => "false", :failed => "true"})
				flash[:error] = "Incorrect Password For Selected Team"
			end
		end

		if @captcha == true
			session[:showedcaptcha] = true
		end
	end
	def logout
		session[:team] = nil
        @mixpanel.track_event("Logout", {:team => @team.name, :admin=>!!session[:user]}) if @team
		redirect_to root_url
	end
	def is_correct_team
		# Checks if a team has the rights to perform this action.
		if not session[:user].nil? and session[:user].is_admin
			return
		end
        if not @team
          return redirect_to :root
        end
		if @team.id != params[:id].to_i
			return redirect_to edit_team_url(session[:team])
		end		
	end
end
