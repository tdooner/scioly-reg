class TeamsController < ApplicationController
  before_filter :is_correct_team, :only => [:edit, :update, :show]

  def show
  end

  def edit
    @this_team = Team.find(params[:id])
  end

  def update
    @this_team = Team.find(params[:id])

    user_attributes =
      [:coach, :email, :password_existing, :password, :password_confirmation]
    admin_attributes =
      [:name, :number, :division]

    @valid_attributes = params[:team].select do |k,_|
      user_attributes.include?(k.to_sym) ||
      (@is_admin && admin_attributes.include?(k.to_sym))
    end.with_indifferent_access

    # First, verify the password entered if necessary...
    if !@is_admin
      if Team.encrypt(@valid_attributes[:password_existing]) != @this_team.hashed_password
        flash[:error] = "Current password is incorrect!"
        return redirect_to(edit_team_url(params[:id]))
      end
    end

    # Then handle changing the password if the user desires
    # TODO: Bug: Move this below update_attributes so if an admin changes both
    # the password and the email, the password email is sent to the right place.
    if @valid_attributes[:password].present?
      if @is_admin
        @this_team.password = @valid_attributes[:password]
        if params[:send_email].present? && @this_team.email.present?
          TeamMailer.password_update(@this_team, params[:team][:password]).deliver
        end
      elsif @valid_attributes[:password] == @valid_attributes[:password_confirmation]
        @this_team.password = @valid_attributes[:password]
      else
        flash[:error] = "Passwords do not match!"
        return redirect_to(edit_team_url(params[:id]))
      end
    else
      @valid_attributes.delete(:password)
      @valid_attributes.delete(:password_confirmation)
    end

    # Commit!
    if !@this_team.update_attributes(@valid_attributes)
      flash[:error] = "A save error occurred: " + @this_team.errors.full_messages.first + "."
      @mixpanel.track("Team Update",
        team: @this_team.name,
        admin: @is_admin,
        failed: false,
      )
      redirect_to edit_team_url(@this_team.id)
    else
      flash[:message] = "Saved!"
      @mixpanel.track("Team Update",
        team: @this_team.name,
        admin: @is_admin,
        failed: true,
      )
      redirect_to edit_team_url(@this_team.id)
    end
  end

  def login
    if session[:loginattempts].nil?
        session[:loginattempts] = 0
        session[:showedcaptcha] = false
    end
    @captcha = false
    if session[:loginattempts] > 3
        @captcha = true
    end

    team_arel = @current_tournament.teams.includes(:tournament).order(:name)
    team_arel = team_arel.where(division: params[:division]) if params[:division].present?
    @teams = team_arel.load

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
        @mixpanel.track("Changed is_admin", {:team_id => params[:team][:id], :ip => request.remote_ip})
        return redirect_to login_teams_path
      end
      if team = Team.authenticate(params[:team][:id], params[:password])
        @mixpanel.track("Login", {:team => team.name, :admin=>"false", :failed => "false"})
        session[:team] = team.id
        flash[:message] = "Logged in!"
        session[:loginattempts] = nil
        return redirect_to :root
      else
        # If the user is logged in as an admin
        if @is_admin
            team = Team.find(params[:team][:id])
            @mixpanel.track("Login", {:team => team.name, :admin=>"true", :failed => "false"})
            session[:team] = team.id
            session[:loginattempts] = nil
            return redirect_to :root
        end
        @mixpanel.track("Login", {:team => Team.find_by_id(params[:team][:id]).name, :admin => "false", :failed => "true"})
        flash[:error] = "Incorrect Password For Selected Team"
        return redirect_to login_teams_path
      end
    end

    if @captcha == true
      session[:showedcaptcha] = true
    end
  end

  def logout
    session[:team] = nil
    @mixpanel.track("Logout", {:team => @team.name, :admin=>@is_admin}) if @team
    redirect_to root_url
  end

  def qualify
    @team = Team.find(params[:id])
    @team.update_attribute(:qualified, !@team.qualified)
    redirect_to admin_teams_path
  end

private

  # Checks if a team has the rights to perform this action.
  def is_correct_team
    return true if @is_admin
    return redirect_to(:root) unless @team

    if @team.id != params[:id].to_i
      return redirect_to edit_team_url(session[:team])
    end
  end
end
