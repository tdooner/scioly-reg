class SchedulesController < ApplicationController
  def index
    breadcrumbs.add('Register For Events')
    if not @team.nil?
      @has_registered = Hash.new()
      @all_schedules[@team.division].map{ |e| @has_registered[e.id] = e.hasTeamRegistered(@team)}
    end
  end

  # TODO: Move the pdf logic to Admit::SchedulesController
  def show
    @schedule = Schedule.find(params[:id])
    breadcrumbs.add("Division #{@schedule.division} Events", division_schedules_url(@schedule.division))
    @scores = @schedule.scores.includes(team: :tournament)
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
        if !@is_admin
          flash[:error] = 'You must be a tournament administrator to download event registration PDFs. Please contact the tournament director if you need a PDF for yourself.'
          redirect_to schedule_url(@schedule)
        end

        render :pdf => @schedule.event.gsub(/[^a-zA-Z]/, '_') + "_" + @schedule.division
      end
      format.html do
        render :show
      end
    end
  end
end
