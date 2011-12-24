# This controller will mostly be a "behind the scenes" deal
class SignupsController < ApplicationController
  def new
	  @signup = SignUp.new(:timeslot_id => params[:id])
	  
	  # If the user has somehow arrived here without
	  # logging in.
	  if session[:team].nil?
		  flash[:error] = "You must log in to sign up for events!"
		  redirect_to login_url(@signup.timeslot.schedule.division)
	  end
	  
	  @signup.team = session[:team]
	  
	  if not @signup.valid?
		  flash[:error] = @signup.errors.full_messages().first
		  redirect_to(schedule_url(@signup.timeslot.schedule))
	  end

	  breadcrumbs.add(@signup.timeslot.schedule.event, url_for(@signup.timeslot.schedule))
	  breadcrumbs.add("Register")
  end

  def list
	  @sign_ups = session[:team].sign_ups.reload
	  breadcrumbs.add("Team #" + session[:team].getNumber() + " Registrations")
  end

  def destroy
	  @signup = SignUp.find(params[:id])

	  schedule = Schedule.first
	  if not @signup.nil? and @signup.team_id == session[:team].id
		  schedule = @signup.delete().timeslot.schedule
	  end

	  flash[:message] = "Registration deleted."

	  return redirect_to(schedule_url(schedule))
  end

  def create
	  @signup = SignUp.new(:timeslot_id => params[:id])
	  
	  # If the user has somehow arrived here without
	  # logging in.
	  if session[:team].nil?
		  flash[:message] = "You must log in to sign up for events!"
		  redirect_to login_url(@signup.timeslot.schedule.division)
	  end
	  
	  @signup.team = session[:team]
	  
	  if not @signup.valid?
		  flash[:message] = @signup.errors.full_messages().first
		  redirect_to(schedule_url(@signup.timeslot.schedule))
	  end
	  if @signup.save()
		  redirect_to(schedule_url(@signup.timeslot.schedule))
	  else
		  flash[:message] = "Error in registering! Your registration did not save."
	  end

  end

end
