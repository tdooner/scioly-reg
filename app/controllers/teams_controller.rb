class TeamsController < ApplicationController
  before_filter :is_admin, :only => [:new, :create, :batchnew, :batchcreate,
                                     :batchpreview, :index, :destroy, :qualify]
  before_filter :is_correct_team, :only => [:edit, :update]

  def index
    @teams = @current_tournament.teams.includes(:tournament)

    breadcrumbs.add("Teams")
  end

  def edit
    @this_team = Team.find(params[:id])
    breadcrumbs.add("Teams", teams_url)
    breadcrumbs.add("Edit Team #" + @this_team.getNumber())
  end

  def update
    @this_team = Team.find(params[:id])

    # First, verify the password entered if necessary...
    if !@is_admin
      if Team.encrypt(params[:team][:password_existing]) != @this_team.hashed_password
        flash[:error] = "Current password is incorrect!"
        return redirect_to(edit_team_url(params[:id]))
      end
    end

    # Then handle changing the password if the user desires
    # TODO: Bug: Move this below update_attributes so if an admin changes both
    # the password and the email, the password email is sent to the right place.
    if params[:team][:password].present?
      if @is_admin
        @this_team.password = params[:team][:password]
        if params[:send_email].present? && @this_team.email.present?
          TeamMailer.password_update(@this_team, params[:team][:password]).deliver
        end
      elsif params[:team][:password] == params[:team][:password_confirmation]
        @this_team.password = params[:team][:password]
      else
        flash[:error] = "Passwords do not match!"
        return redirect_to(edit_team_url(params[:id]))
      end
    else
      params[:team].delete(:password)
      params[:team].delete(:password_confirmation)
    end

    # Commit!
    if !@this_team.update_attributes(@is_admin ? team_admin_attributes : team_user_attributes)
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

  def new
    breadcrumbs.add("Create Team")
    @this_team = Team.new
  end

  def batchnew
    breadcrumbs.add("Create Team", new_team_url)
    breadcrumbs.add("Batch Mode")
  end

  def batchcreate
    @teams, @errors = parse_teams_from_batch

    @teams.each do |team|
      if team.save
        if params[:send_email].present? && team.email.present?
          TeamMailer.password_update(team, team.password).deliver
        end
      else
        @errors << "Error with #{team.name}: #{team.errors.full_messages.first}"
      end
    end

    flash[:error] = @errors.first(3).join("<br />") unless @errors.empty?

    if not flash[:error]
      redirect_to teams_url
    else
      render :batchnew
    end
  end

  def batchpreview
    return unless request.xhr?
    @teams, @errors = parse_teams_from_batch

    render layout: false
  end

  def destroy
    @team = Team.find(params[:id])

    unless @current_admin.is_admin_of(@team.tournament.school)
      flash[:error] = 'Unauthorized!'
      return redirect_to root_url
    end

    if @team.destroy
      flash[:message] = 'Team deleted!'
    else
      flash[:error] = 'Could not delete team!'
    end

    redirect_to teams_url
  end

  def create
    @this_team = Team.new(params.fetch(:team, {}).permit(:name, :coach, :email,
                                                         :password, :division,
                                                         :number, :homeroom))
    @this_team.tournament = @current_tournament
    if @this_team.save
        flash[:message] = "Done!"

        if params[:send_email].present?
          TeamMailer.password_update(@this_team, params[:team][:password]).deliver
        end

        redirect_to :teams
    else
        flash[:error] = "Error: #{@this_team.errors.full_messages.first}"

        render :new
    end

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

    @teams = @current_tournament.teams.where('division = ?', params[:division]).includes(:tournament).sort_by(&:name)
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
        return redirect_to division_login_path(params[:division])
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
        return redirect_to division_login_path(params[:division])
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
    redirect_to teams_path
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

  def parse_teams_from_batch
    return [[], ['No teams specified!']] unless params[:batch].present?

    lines = params[:batch].split("\n")
    errors = []
    team_numbers = @current_tournament.teams.pluck(:number)
    team_names = @current_tournament.teams.pluck(:name)

    teams = lines.map do |t|
      a = t.strip.split("\t")

      if a.length < 7
        errors << "Short record found: #{a[0]}!"
        next
      end

      if team_names.include?(a[0])
        errors << "Duplicate team name: #{a[0]}"
      end

      if team_numbers.include?(a[1])
        errors << "Duplicate team number for team #{a[0]}"
      end

      team_names << a[0]
      team_numbers << a[1]

      @current_tournament.teams.new(
        :name => a[0],
        :number => a[1],
        :coach => a[2],
        :email => a[3],
        :division => a[4],
        :homeroom => a[5],
        :password => a[6],
      )
    end

    [teams, errors]
  end

  def team_user_attributes
    params.fetch(:team, {})
      .permit(:coach, :email, :password_existing, :password, :password_confirmation)
  end

  def team_admin_attributes
    params.fetch(:team, {})
      .permit(:coach, :email, :password_existing, :password, :password_confirmation,
        :name, :number, :division, :homeroom)
  end
end
