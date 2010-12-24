class SchedulesController < ApplicationController
	####
	# A "schedule" means a "scheduled event" for a given
	# tournament and division. In other words, a "schedule"
	# is what a team registers to.
	###
  def list
	  @schedules = Schedule.find(:all)
  end

  def new
	  @schedule = Schedule.new()
  end

  def create
	@schedule = Schedule.new(params[:schedule])
	if @schedule.save()
		render :list
	else
		flash[:message] = "Error creating the event schedule"
		render :new
	end
  end

  def index
	  @schedules = Schedule.find(:all)
	  render :list
  end
 
end
