class SchedulesController < ApplicationController
	####
	# A "schedule" means a "scheduled event" for a given
	# tournament and division. In other words, a "schedule"
	# is what a team registers to.
	###
	
  before_filter CASClient::Frameworks::Rails::Filter, :only => :new

  def list
	  breadcrumbs.add('Register For Events')
	  @schedules = Schedule.find(:all)
	  if not session[:team].nil?
		  @sign_ups = session[:team].sign_ups.map{|x| x.schedule_id}
	  end
  end

  def new
	  @schedule = Schedule.new()
  end

  def create
	@schedule = Schedule.new(params[:schedule])
	if @schedule.save()
		redirect_to :list
	else
		flash[:message] = "Error creating the event schedule"
		render :new
	end
  end

  def index
	@schedules = Schedule.find(:all)
	breadcrumbs.add('Register For Events')
    if not session[:team].nil?
  	    @sign_ups = Team.find(session[:team].id).sign_ups.map{|x| x.schedule_id}
    end
	render :list
  end

  def show
	@schedule = Schedule.find(params[:id])
	breadcrumbs.add(@schedule.event) 
	if @schedule.nil?
		flash[:message] = "Event not found!"
		# render :somethingelse
	end
	# Generate a hash (@timeslots) of all time slots
	#   11:00:00 => nil
	#   11:15:00 => nil
	#      ...   => nil
	#   12:45:00 => nil
	# And then merge that hash with the current
	#  sign-ups so the view needs only worry
	#  about one hash, @taken.
		
	@timeslots = Hash[@schedule.getTimeSlots().map{|x| [x, nil]}]
	@taken = SignUp.getSignUps(@schedule.id)
	@allslots = @timeslots.merge(@taken)
  end
end
