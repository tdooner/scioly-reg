class TournamentsController < ApplicationController
  before_filter :is_admin, :except => :scores
  protect_from_forgery :except => :destroy

  def create
    @tournament = Tournament.new(params[:tournament])
    @tournament.school = @current_school
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
    @tournaments = @current_school.tournaments
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

  def scores
    @active = Tournament.find(params[:tournament_id])
    if !@active.show_scores? && !(session[:user] && session[:user].is_admin_of(@current_school))
      flash[:error] = "Scores for this tournament are not available yet."
      return redirect_to root_url
    end
    breadcrumbs.add(@active.humanize + " Scores")
    @events = @active.schedules.includes({:scores => :team}).sort_by(&:event).group_by{|x| x.division}
    @teams = @active.teams

    # @team_ranks is an array of sorted [team.rank_matrix, #<Team Object>] tuples
    @teams_by_rank = @teams.reduce({}){|a,i| a.merge({i => i.rank_matrix})}.sort_by{|k,v| v}
    @teams_by_rank = @teams_by_rank.group_by{|x| x[0].division}

    @layout_expanded = true
  end

  def scoreslideshow
    if not params[:slideshow]
      return redirect_to admin_scoreslideshow_url
    end
    @events = @current_tournament.schedules.includes({:scores => :team})
    @teams = @current_tournament.teams.includes(:scores)

    @events.keep_if{|x| params[:slideshow][:division].include?(x.division) }
    @events.keep_if{|x| !x.scores.empty?}
    @events.keep_if{|x| !x.scores_withheld || params[:slideshow][:skip_withheld] == "false"}
    case params[:slideshow][:order]
    when "alpha"
      @events = @events.sort_by(&:event)
    when "alphadiv"
      @events = @events.sort_by(&:event).group_by(&:division).values.flatten
    when "random"
      @events = @events.shuffle
    when "randomdiv"
      @events = @events.group_by(&:division).values.map(&:shuffle).flatten
    end

    @teams_by_rank = @teams.reduce({}){|a,i| a.merge({i => i.rank_matrix})}.invert.sort
    @teams_by_rank = @teams_by_rank.group_by{|x| x[1].division}

    @places = ["First Place", "Second Place", "Third Place", "Fourth Place", "Fifth Place", "Sixth Place", "Seventh Place", "Eigth Place"]
    render :slideshow, :layout=>"scoreslideshow"
  end
end
