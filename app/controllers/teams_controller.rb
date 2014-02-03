class TeamsController < ApplicationController
  before_filter :is_admin, :only => [:new, :create, :batchnew, :index, :destroy]
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

      if a.length < 7
        @errors << "Short record found: #{a[0]}!"
        next
      end

      team = @current_tournament.teams.new(
        :name => a[0],
        :number => a[1],
        :coach => a[2],
        :division => a[3],
        :homeroom => a[4],
        :password => a[5],
        :email => a[6].strip,
      )

      if team.save
        if params[:send_email].present? && team.email.present?
          TeamMailer.password_update(team, team.password).deliver
        end
      else
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
                                                         :number))
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
        return redirect_to login_url(params[:division])
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

  # Checks if a team has the rights to perform this action.
  def is_correct_team
    return true if @is_admin
    return redirect_to(:root) unless @team

    if @team.id != params[:id].to_i
      return redirect_to edit_team_url(session[:team])
    end
  end
end
