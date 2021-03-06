class TournamentsController < ApplicationController
  before_filter :is_admin, :except => :scores
  before_filter :verify_scores_visible, only: :scores
  protect_from_forgery :except => :destroy

  def create
    Tournament.transaction do
      @tournament = Tournament.new(tournament_params)
      @tournament.school = @current_school

      if params[:copy_tournament_id].present?
        copy_tournament = Tournament.find_by(id: params[:copy_tournament_id])
        @tournament.schedules = copy_tournament.schedules.map do |old_schedule|
          old_schedule.dup.tap do |new_schedule|
            new_schedule.tournament_id = nil
            new_schedule.scores_withheld = false
          end
        end
      end

      unless @tournament.valid?
        flash[:error] = "Error: #{@tournament.errors.full_messages.first}"
      end

      @tournament.save
    end

    redirect_to :tournaments
  end

  def new
    @tournament = @current_school.tournaments.new
    breadcrumbs.add("New Tournament")
  end

  def edit
    @tournament = Tournament.find(params[:id])
    breadcrumbs.add("Edit Tournaments", tournaments_url)
    breadcrumbs.add("Tournament on " + @tournament.humanize)
  end

  def index
    @tournaments = @current_school.tournaments.order(:date)
    breadcrumbs.add("Edit Tournaments")
  end

  def show
    @tournament = Tournament.find(params[:id])
    breadcrumbs.add(@tournament.humanize() + " Tournament")
  end

  def update
    @t = Tournament.find(params[:id])
    @t.update_attributes(tournament_params)
    redirect_to :tournaments
  end

  def destroy
    tournament = Tournament.find(params[:id])

    if tournament.school.tournaments.count > 1
      tournament.destroy

      # Make sure that the user can't accidentally delete the active tournament
      if tournament.is_current
        previous_tournament = tournament.school.tournaments.order('date DESC').first
        previous_tournament.set_current
        flash[:message] = "Automatically set current tournament to #{previous_tournament.humanize}"
      end
    else
      flash[:error] = "You cannot delete your only tournament!"
    end

    redirect_to :tournaments
  end

  def set_active
    @active = Tournament.find(params[:current])
    @active.set_current()
    redirect_to :tournaments
  end

  def scores
    @active = Tournament.find(params[:tournament_id])
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

    @divisions = params[:slideshow][:division].try(:keys)

    unless @divisions.any?
      return redirect_to(admin_scoreslideshow_url, flash: {
        error: 'Error: You must select a division!'
      })
    end

    @events = @current_tournament.schedules.includes({:scores => { :team => :tournament } })
    @teams = @current_tournament.teams.includes([:scores, :tournament])

    @events.keep_if{|x| @divisions.include?(x.division) }
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

    @places = ['First Place', 'Second Place', 'Third Place', 'Fourth Place',
      'Fifth Place', 'Sixth Place', 'Seventh Place', 'Eighth Place']

    render :slideshow, :layout=>"scoreslideshow"
  end

  def load_default_events
    @tournament = Tournament.find(params[:tournament_id])

    @tournament.load_default_events

    redirect_to admin_events_url
  end

  def publish_scores
    @tournament = Tournament.find(params[:tournament_id])
    if @tournament.update_attribute(:scores_revealed, true)
      flash[:message] = "Scores published!"
      redirect_to tournament_scores_url(@tournament)
    else
      flash[:error] = "Could not publish scores!"
      redirect_to admin_scorespublish_url
    end
  end

  private

  def verify_scores_visible
    tournament = Tournament.find(params[:tournament_id])
    if !tournament.show_scores? && !@is_admin
      flash[:error] = "Scores for this tournament are not available yet."
      redirect_to root_url
    end
  end

  def tournament_params
    params.fetch(:tournament, {}).permit(:title, :date, :registration_begins,
                                         :registration_ends, :homepage_markdown,
                                         :homepage_photo, :hosted_by_markdown,
                                         :append_division_to_team_number)
  end
end
