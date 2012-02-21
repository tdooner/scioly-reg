# This controller will mostly be a "behind the scenes" deal
class SignupsController < ApplicationController
  before_filter :load_signup_by_timeslot_id, :only => [:new, :create]
  before_filter :load_signup_by_signup_id, :only   => [:destroy]
  before_filter :ensure_registration_open, :only => [:new, :create, :destroy]

  def new
	  # If the user has somehow arrived here without
	  # logging in.
	  if not @team
		  flash[:error] = "You must log in to sign up for events!"
		  redirect_to login_url(@signup.timeslot.schedule.division)
	  end
	  
	  @signup.team = @team
	  if not @signup.valid?
		  flash[:error] = @signup.errors.full_messages().first
		  redirect_to(schedule_url(@signup.timeslot.schedule))
	  end

      @is_admin_signup = (!@signup.timeslot.schedule.tournament.can_register() && session[:user] && session[:user].can_register_team_for_event?(@team, @signup.timeslot.schedule))

	  breadcrumbs.add(@signup.timeslot.schedule.event, url_for(@signup.timeslot.schedule))
	  breadcrumbs.add("Register")
  end

  def list
	  @sign_ups = @team.sign_ups.reload
	  breadcrumbs.add("Team #" + @team.getNumber() + " Registrations")
  end

  def destroy
	  schedule = Schedule.first
	  if not @signup.nil? and @signup.team_id == @team.id
		  schedule = @signup.delete().timeslot.schedule
	  end

	  flash[:message] = "Registration deleted."

      @mixpanel.track_event("SignUp Destroy", {:team => @team.name, :event=>@signup.timeslot.schedule.event})
	  return redirect_to(schedule_url(schedule))
  end

  def create
	  # If the user has somehow arrived here without
	  # logging in.
	  if not @team
		  flash[:message] = "You must log in to sign up for events!"
		  redirect_to login_url(@signup.timeslot.schedule.division)
	  end
	  
	  @signup.team = @team
	  
	  if not @signup.valid?
		  flash[:message] = @signup.errors.full_messages().first
		  redirect_to(schedule_url(@signup.timeslot.schedule))
	  end
	  if @signup.save()
        @mixpanel.track_event("SignUp Create", {:team => @team.name, :event=>@signup.timeslot.schedule.event, :success => true})
		redirect_to(schedule_url(@signup.timeslot.schedule))
	  else
        @mixpanel.track_event("SignUp Create", {:team => @team.name, :event=>@signup.timeslot.schedule.event, :success => false})
		flash[:message] = "Error in registering! Your registration did not save."
	  end

  end

  def load_signup_by_timeslot_id
    @signup = SignUp.new(:timeslot_id => params[:id])
  end
  def load_signup_by_signup_id
    @signup = SignUp.find(params[:id])
  end

  def ensure_registration_open
    return if session[:user] && @team && session[:user].can_register_team_for_event?(@team, @signup.timeslot.schedule)

    unless @signup.timeslot.schedule.tournament.can_register()
      flash[:error] = "Registration is not open for the current tournament!"
      redirect_to(schedule_url(@signup.timeslot.schedule))
    end

  end

end
