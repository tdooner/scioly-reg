class TimeslotsController < ApplicationController
  before_filter :is_admin
  protect_from_forgery :except=>[:destroy]

  def create
    ts = Timeslot.new(params[:timeslot]) 
    ts.schedule_id = params[:timeslot_extra][:schedule].to_i
    # For now, set the timeslot's end time to shortly after its begin time, since the timeslot end time
    # is not displayed anywhere and will be removed in a later version.
    ts.ends = ts.begins
    return redirect_to root_url unless session[:user].can_edit?(ts.schedule)
    if !ts.save
      flash[:error] = "Timeslot not created: #{ts.errors.full_messages.first}"
    end
    redirect_to schedule_url(ts.schedule)
  end

  def update
    ts = Timeslot.find(params[:id])
    return redirect_to root_url unless session[:user].can_edit?(ts.schedule)
    if !ts.update_attributes(params[:timeslot])
      flash[:error] = "There was a problem saving the timeslot data: #{ts.errors.full_messages.first}. #{params[:timeslot][:begins].inspect}"
    end
    redirect_to schedule_url(ts.schedule) 
  end

  def destroy
    ts = Timeslot.find(params[:id])
    return redirect_to root_url unless session[:user].can_edit?(ts.schedule)
    if !ts.destroy
      flash[:error] = "Could not delete!"
    end
    redirect_to schedule_url(ts.schedule) 
  end
end
