class SchedulesController < ApplicationController
	####
	# A "schedule" means a "scheduled event" for a given
	# tournament and division. In other words, a "schedule"
	# is what a team registers to.
	###

  before_filter :is_admin, :only => [:new, :destroy]
  protect_from_forgery :except => :destroy

# def list
#	  breadcrumbs.add('Register For Events')
#	  if not session[:team].nil?
#		  @sign_ups = session[:team].sign_ups.map{|x| x.schedule_id}
#	      @schedules = Schedule.find(:all, :conditions => ["division = ?", session[:team].division])
#	  else
#	      @schedules = Schedule.find(:all)
#	  end
# end

  def new
	  breadcrumbs.add("New Event")
	  @schedule = Schedule.new()
  end

  def create
	@schedule = Schedule.new(params[:schedule])
	if @schedule.save() and @schedule.updateTimeSlots()
		redirect_to :schedules
	else
		flash[:message] = "Error creating the event schedule"
		render :new
	end
  end

  def index
	breadcrumbs.add('Register For Events')
    if not session[:team].nil?
	    @schedules = Schedule.find(:all, :conditions => ["division = ?", session[:team].division], :order => ["event ASC"])
		@has_registered = Hash.new()
		@schedules.map{ |x| @has_registered[x.id] = x.hasTeamRegistered(session[:team])}
	else
		@schedules = Schedule.find(:all, :order => ["event ASC"])
    end
	render :list
  end

  def show
	breadcrumbs.add('Register For Events', schedules_url)
	@schedule = Schedule.find(params[:id])
	breadcrumbs.add(@schedule.event) 
	if @schedule.nil?
		flash[:message] = "Event not found!"
		# render :somethingelse
	end

	@allslots = @schedule.timeslots.sort { |x,y| x.begins <=> y.begins }
	@currentreg = nil
	if not session[:team].nil?
		@currentreg = session[:team].sign_ups.find(:first, :conditions => ["timeslot_id in (select id from timeslots where schedule_id = ?)", @schedule])
	end

	respond_to do |format|
		format.pdf do
			@signed_up_teams = @schedule.timeslots.map {|x| x.sign_ups.map{ |y| y.team } }.flatten.to_set
			@teams_remaining = Team.find(:all, :conditions => ["division = ?", @schedule.division], :order => ["name ASC"]).to_set.difference(@signed_up_teams)
			render :pdf => @schedule.event.gsub(/[^a-zA-Z]/, '_') + "_" + @schedule.division
		end
		format.html do
			render :show
		end
	end
  end

  def destroy
	@schedule = Schedule.find(params[:id])
	@schedule.timeslots do |e|
		e.sign_ups.delete_all()
		e.delete()
	end
	@schedule.delete()
	redirect_to :schedules
  end
end
