class TournamentsController < ApplicationController
  before_filter :is_admin
  protect_from_forgery :except => :destroy

  def create
	  @tournament = Tournament.new(params[:tournament])
	  @tournament.save()
	  redirect_to :tournaments
  end

  def new
	  @tournament = Tournament.new()
	  breadcrumbs.add("New Tournament")
  end

  def edit
	  @tournament = Tournament.find(params[:id])
	  breadcrumbs.add("Edit Tournament #" + @tournament.id.to_s)
  end

  def index
	  @tournaments = Tournament.find(:all)
	  breadcrumbs.add("Edit Tournaments")
  end

  def show
	  @tournament = Tournament.find(params[:id])
	  breadcrumbs.add(@tournament.humanize() + " Tournament")
  end

  def update
	  @t = Tournament.find(params[:id])
	  @t.update_attributes(params[:tournament])
	  redirect_to :tournaments
  end

  def destroy
	  #TODO: Delete all corresponding events, teams, and signups
	  @t = Tournament.find(params[:id])
	  @t.destroy()
	  redirect_to :tournaments
  end

  def set_active
	  @active = Tournament.find(params[:current])
	  @active.set_current()
	  redirect_to :tournaments
  end

  def scoreslideshow
    logger.debug params.inspect
    @events = @current_tournament.schedules.includes({:scores => :team})
    @teams = @current_tournament.teams.includes(:scores)

    @events.keep_if{|x| params[:slideshow][:division].include?(x.division) }
    @events.keep_if{|x| !x.scores.empty?}
    @events.keep_if{|x| !x.scores_withheld || params[:slideshow][:skip_withheld] == "false"}

    @teams = @teams.sort_by{|x| x.scores.map(&:placement).sum }.group_by(&:division)
    @places = ["First Place", "Second Place", "Third Place", "Fourth Place", "Fifth Place", "Sixth Place", "Seventh Place", "Eigth Place"]
    render :slideshow, :layout=>"scoreslideshow"
  end
end
