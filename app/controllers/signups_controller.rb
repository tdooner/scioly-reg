# This controller will mostly be a "behind the scenes" deal
class SignupsController < ApplicationController
  def new
	  @signup = SignUp.new()
	  @signup.schedule = Schedule.find(params[:id])
	  
	  # If the user has somehow arrived here without
	  # logging in.
	  if session[:team].nil?
		  flash[:message] = "You must log in to sign up for events!"
		  redirect_to login_url(@signup.schedule.division)
	  end
	  
	  @signup.time = Time.at(params[:time].to_i).utc
	  @signup.team = session[:team]
	  
	  if not @signup.valid?
		  flash[:message] = @signup.errors.full_messages().first
		  redirect_to(schedule_url(@signup.schedule))
	  end
  end

  def list
  end

  def create
	  @signup = SignUp.new()
	  @signup.schedule = Schedule.find(params[:id])
	  
	  # If the user has somehow arrived here without
	  # logging in.
	  if session[:team].nil?
		  flash[:message] = "You must log in to sign up for events!"
		  redirect_to login_url(@signup.schedule.division)
	  end
	  
	  @signup.time = Time.at(params[:time].to_i).utc
	  @signup.team = session[:team]
	  
	  if not @signup.valid?
		  flash[:message] = @signup.errors.full_messages().first
		  redirect_to(schedule_url(@signup.schedule))
	  end
	  if @signup.save()
		  redirect_to(schedule_url(@signup.schedule))
	  else
		  flash[:message] = "Error in registering! Your registration did not save."
	  end

  end

end
