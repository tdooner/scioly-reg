class SchedulesController < ApplicationController
	####
	# A "schedule" means a "scheduled event" for a given
	# tournament and division. In other words, a "schedule"
	# is what a team registers to.
	###

  before_filter :is_admin, :only => [:new, :destroy, :batchnew, :create, :scores, :savescores, :batchcreate]
  protect_from_forgery :except => :destroy
  autocomplete :schedule, :event, :display_value => :humanize, :extra_data => [:division]

  def new
	  breadcrumbs.add("New Event")
	  @schedule = Schedule.new()
  end

  def batchnew
    breadcrumbs.add("New Event", new_schedule_url())
    breadcrumbs.add("Batch Mode")
  end

  def create
	@schedule = @current_tournament.schedules.create(params[:schedule])
	if @schedule 
      if params[:schedule_online] == "true"
        @schedule.updateTimeSlots()
      end
      redirect_to :schedules
	else
      flash[:message] = "Error creating the event schedule. "
      flash[:error] = @schedule.errors.full_messages.first
      render :new
	end
  end

  def batchcreate
    schedules = params[:batch].split("\n")
    @errors = []

    schedules.each do |s|
      a = s.strip.split("\t")
      if a.length < 7
        @errors << "Schedule #{a[0]} does not have enough fields."
        next
      end
      schedule = @current_tournament.schedules.new({:event=>a[0], :division=>a[1], :room=>a[2], :starttime=>DateTime.parse(a[3]).to_time, :endtime => DateTime.parse(a[4]).to_time, :num_timeslots => a[5].to_i, :teams_per_slot => a[6].to_i})
      if schedule.save()
        if schedule.num_timeslots != 0
          res = schedule.updateTimeSlots
          if !res.is_a?(Array)
            @errors << "#{res} with #{a[0]}. No timeslots have been created for this event."
          end
        end
      else
        @errors << schedule.errors.full_messages.first 
      end
    end
    flash[:error] = @errors.join("<br />") unless @errors.empty?

    if not flash[:error]
      redirect_to admin_events_url
    else
      render :batchnew
    end
  end

  def index
	breadcrumbs.add('Register For Events')
    if not @team.nil?
		@has_registered = Hash.new()
		@all_schedules[@team.division].map{ |e| @has_registered[e.id] = e.hasTeamRegistered(@team)}
    end
	render :list
  end

  def show
	@schedule = Schedule.find(params[:id])
	breadcrumbs.add("Division #{@schedule.division} Events", schedule_division_url(@schedule.division))
    @scores = @schedule.scores.includes(:team)
	breadcrumbs.add(@schedule.event) 
	if @schedule.nil?
		flash[:message] = "Event not found!"
		# render :somethingelse
	end

	@allslots = @schedule.timeslots.sort { |x,y| x.begins <=> y.begins }
	@currentreg = nil
	if @team 
		@currentreg = SignUp.find_by_team_id_and_timeslot_id(@team, @allslots.map{|x| x.id})
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
	redirect_to :admin_events
  end

  def scores
    @schedule = Schedule.find(params[:schedule_id], :include => :scores)
    @teams = @current_tournament.teams.where(["division = ?", @schedule.division])
    @placements = @teams.inject({}) { |a,i| 
      s = @schedule.scores.select{|x| x.team_id == i.id}.first
      if s
        a.merge(i.id => s.placement) 
      else
        a.merge(i.id => "") 
      end
    }
    breadcrumbs.add("Scoring", "/admin/scores")
    breadcrumbs.add(@schedule.humanize)
  end

  def savescores
    @schedule = Schedule.find(params[:schedule_id])
    @teams = @current_tournament.teams.where(["division = ?", @schedule.division])

    @schedule.scores.delete_all
    params[:placings].each do |k,v|
      @schedule.scores.create({:team_id => k, :placement => v})
    end

    if params[:scores_withheld] == "true"
      @schedule.update_attribute(:scores_withheld, true)
    else
      @schedule.update_attribute(:scores_withheld, false)
    end

    redirect_to admin_scores_url()
  end
end
