class TimeslotsController < ApplicationController
  before_filter :is_admin
  before_filter :verify_admin_can_edit
  protect_from_forgery :except=>[:destroy]

  def create
    ts = Timeslot.new(params[:timeslot])
    ts.schedule_id = params[:timeslot_extra][:schedule].to_i
    # For now, set the timeslot's end time to shortly after its begin time, since the timeslot end time
    # is not displayed anywhere and will be removed in a later version.
    ts.ends = ts.begins
    if !ts.save
      flash[:error] = "Timeslot not created: #{ts.errors.full_messages.first}"
    end
    redirect_to schedule_url(ts.schedule)
  end

  def update
    ts = Timeslot.find(params[:id])
    if !ts.update_attributes(params[:timeslot])
      flash[:error] = "There was a problem saving the timeslot data: #{ts.errors.full_messages.first}. #{params[:timeslot][:begins].inspect}"
    end
    redirect_to schedule_url(ts.schedule)
  end

  def destroy
    ts = Timeslot.find(params[:id])
    if !ts.destroy
      flash[:error] = "Could not delete!"
    end
    redirect_to schedule_url(ts.schedule)
  end

private

  def verify_admin_can_edit
    redirect_to root_url unless @current_admin.can_edit?(ts.schedule)
  end
end
