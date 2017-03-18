class HomeController < ApplicationController
  before_filter :render_app_if_subdomain, :only => :index
  before_filter :redirect_to_app_if_subdomain, :except => :index

  def index
    render :index, :layout => 'static_page'
  end

  def team_home
      return redirect_to root_url unless @team
      breadcrumbs.add("Welcome!")
      render :signup # Render app/views/home/signup.html.haml
  end

  def about
    render :about, :layout => 'static_page'
  end

  def newschool
    render :newschool, :layout => 'static_page'
  end

  def createschool
    @school = School.new(school_params)

    @director = User.new(params.fetch(:tournament_director, {}).permit(:password))
    @director.email = params[:school][:admin_email]
    @director.role = 1          # Role 1 = Admin

    @tournament = Tournament.new(params.fetch(:tournament, {}).permit(:title, :date))

    if !verify_recaptcha
      flash[:error] = "Error: Image verification failed. Pleas try again!"
      return render :newschool, layout: 'static_page'
    end

    if @school.save
      @director.school = @school
      @tournament.school = @school

      # Set some default values...
      # TODO: Make these not happen here
      @tournament.is_current          = true
      @tournament.registration_begins = @tournament.date - 3.weeks
      @tournament.registration_ends   = @tournament.date - 1.week

      if @director.save
        if @tournament.save
          # Prepopulate the event list:
          @tournament.load_default_events

          @school_url = @school.url(request.domain)
          HomeMailer.welcome(@tournament).deliver
          render :createdschool, :layout => 'static_page'
        else
          flash[:error] = "Error: Could not create tournament for
            #{@school.name}. The following error occurred:
            #{@tournament.errors.full_messages.first}. This is a site error."
          render :newschool, :layout => 'static_page'
        end
      else
        flash[:error] = "Error: Could not create administrator user for
          #{@school.name}. The following error occurred:
          #{@director.errors.full_messages.first}"
        render :newschool, :layout => 'static_page'
      end
    else
      flash[:error] = "Error: We could not register your school. The following
        error occurred: #{@school.errors.full_messages.first}"
      render :newschool, :layout => 'static_page'
    end
  end

  def force_error
    raise 'Testing Error For Sentry'
  end

  private

  def school_params
    params.fetch(:school, {})
      .permit(:name, :time_zone, :admin_name, :admin_email, :subdomain, :logo)
  end

  def signup
    breadcrumbs.add("Welcome!")
    render :signup # Render app/views/home/signup.html.haml
  end

  def login
    render :login
  end

  def render_app_if_subdomain
    if @current_school
      if @team
        signup
      else
        login
      end
    end
  end

  def redirect_to_app_if_subdomain
    # Redirect from http://cwru.sciolyreg.org/about to
    # http://sciolyreg.org/about.
    #
    # Also, the port stuff is here for local development.
    host = (request.port == 80) ? "#{request.domain}" :
      "#{request.domain}:#{request.port}"
    redirect_to url_for(:action => action_name, :host => host) if @current_school
  end
end
