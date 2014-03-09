class HomeController < ApplicationController
  before_filter :redirect_to_app_if_subdomain, :except => :index

  layout 'no_school'

  def index
    @schools = School.all
  end

  def logged_in
  end

  def about
  end

  def newschool
  end

  def createschool
    @school = School.new(params.fetch(:school, {}).permit(:name, :time_zone, :admin_name, :admin_email, :subdomain))

    @director = User.new(params.fetch(:tournament_director, {}).permit(:password))
    @director.email = params[:school][:admin_email]
    @director.role = 1          # Role 1 = Admin

    @tournament = Tournament.new(params.fetch(:tournament, {}).permit(:title, :date))

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
          render :createdschool
        else
          flash[:error] = "Error: Could not create tournament for
            #{@school.name}. The following error occurred:
            #{@tournament.errors.full_messages.first}. This is a site error."
          render :newschool
        end
      else
        flash[:error] = "Error: Could not create administrator user for
          #{@school.name}. The following error occurred:
          #{@director.errors.full_messages.first}"
        render :newschool
      end
    else
      flash[:error] = "Error: We could not register your school. The following
        error occurred: #{@school.errors.full_messages.first}"
      render :newschool
    end
  end

  private

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
