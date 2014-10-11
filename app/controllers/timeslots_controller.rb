class TimeslotsController < ApplicationController
  before_filter :set_timeslot, except: :create
  before_filter :is_admin
  before_filter :verify_admin_can_edit, except: :create

  def create
    ts = Timeslot.new(timeslot_params)
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
    if !@timeslot.update_attributes(timeslot_params)
      flash[:error] = "There was a problem saving the timeslot data: #{@timeslot.errors.full_messages.first}. #{params[:timeslot][:begins].inspect}"
    end

    redirect_to schedule_url(@timeslot.schedule, anchor: 'tab-registration')
  end

  def destroy
    if !@timeslot.destroy
      flash[:error] = "Could not delete!"
    end

    redirect_to schedule_url(@timeslot.schedule)
  end

private

  def set_timeslot
    @timeslot = Timeslot.find(params[:id])
  end

  def verify_admin_can_edit
    redirect_to root_url unless @current_user.can_edit?(@timeslot.schedule)
  end

  def timeslot_params
    params.fetch(:timeslot, {}).permit(:begins, :team_capacity)
  end
end
