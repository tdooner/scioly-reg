class SchoolsController < ApplicationController
  before_filter :ensure_logged_in

  layout 'no_school'

  def new
    @school = School.new
  end
  
  def create
    @school = School.new(params.fetch(:school, {}).permit(:name, :time_zone, :subdomain))

    @tournament = Tournament.new(params.fetch(:tournament, {}).permit(:title, :date, divisions: []))

    if @school.save
      Administration.create(user: @current_user, administrates: @school)

      @tournament.school = @school

      # Set some default values...
      # TODO: Make these not happen here
      @tournament.is_current          = true
      @tournament.registration_begins = @tournament.date - 3.weeks
      @tournament.registration_ends   = @tournament.date - 1.week

      if @tournament.save
        # Prepopulate the event list:
        @tournament.load_default_events

        @school_url = @school.url(request.domain)
        HomeMailer.welcome(@tournament).deliver
      else
        flash[:error] = "Error: Could not create tournament for
          #{@school.name}. The following error occurred:
          #{@tournament.errors.full_messages.first}. This is a site error."
        render :newschool
      end
    else
      flash[:error] = "Error: We could not register your school. The following
        error occurred: #{@school.errors.full_messages.first}"
      render :new
    end
  end
end
