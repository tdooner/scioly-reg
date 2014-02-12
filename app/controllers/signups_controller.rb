# This controller will mostly be a "behind the scenes" deal
class SignupsController < ApplicationController
  before_filter :load_signup_by_timeslot_id, :only => [:new, :create]
  before_filter :load_signup_by_signup_id, :only   => [:destroy]
  before_filter :ensure_registration_open, :only => [:new, :create, :destroy]
  before_filter :team_logged_in

  protect_from_forgery except: :destroy

  def new
    @signup = SignUp.new(:timeslot_id => params[:timeslot_id])

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

    breadcrumbs.add(@signup.timeslot.schedule.event, url_for(@signup.timeslot.schedule))
    breadcrumbs.add("Register")
  end

  def index
    @sign_ups = @team.sign_ups.includes(timeslot: :schedule)

    # this shouldn't be needed in the future, but there is some bad data in the
    # database right now:
    @sign_ups.reject! { |s| s.try(:timeslot).try(:schedule).nil? }

    breadcrumbs.add("Team #" + @team.getNumber() + " Registrations")
  end

  def destroy
    @signup = SignUp.find(params[:id])

    if @signup.team_id == @team.id
      flash[:message] = "Registration deleted."
      @signup.destroy
      @mixpanel.track("SignUp Destroy", team: @team.name,
                                        event: @signup.timeslot.schedule.event)
    else
      flash[:error] = 'You cannot delete this timeslot!'
    end

    redirect_to schedule_url(@signup.timeslot.schedule)
  end

  def create
    @signup = SignUp.new(:timeslot_id => params[:timeslot_id])

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
      @mixpanel.track("SignUp Create", {:team => @team.name, :event=>@signup.timeslot.schedule.event, :success => true})
      redirect_to(schedule_url(@signup.timeslot.schedule))
    else
      @mixpanel.track("SignUp Create", {:team => @team.name, :event=>@signup.timeslot.schedule.event, :success => false})
      flash[:message] = "Error in registering! Your registration did not save."
    end
  end

  def load_signup_by_timeslot_id
    @signup = SignUp.new(:timeslot_id => params[:timeslot_id])
  end

  def load_signup_by_signup_id
    @signup = SignUp.find(params[:id])
  end

  def ensure_registration_open
    return if @is_admin && @current_admin.can_register_team_for_event?(@team, @signup.timeslot.schedule)

    if !@signup.timeslot.schedule.tournament.can_register?
      flash[:error] = "Registration is not open for the current tournament!"
      redirect_to(schedule_url(@signup.timeslot.schedule))
    end
  end
end
