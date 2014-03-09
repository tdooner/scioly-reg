class TournamentsController < ApplicationController
  before_filter :verify_scores_visible, only: :scores

  layout 'scorespreadsheet', only: :scores

  def show
  end

  def scores
    @active = Tournament.find(params[:tournament_id], include: { teams: [:tournament, :scores] })

    @events = @active.schedules
                     .includes(scores: :team)
                     .sort_by(&:event)
                     .group_by(&:division)
    @teams = @active.teams

    # @team_ranks is an array of sorted [team.rank_matrix, #<Team Object>] tuples
    @teams_by_rank = @teams.reduce({}) { |a, i| a.merge(i => i.rank_matrix) }
                           .sort_by{|k,v| v}
    @teams_by_rank = @teams_by_rank.group_by {|x| x[0].division}
  end

private

  def verify_scores_visible
    tournament = Tournament.find(params[:tournament_id])
    if !tournament.show_scores? && !@is_admin
      flash[:error] = "Scores for this tournament are not available yet."
      redirect_to root_url
    end
  end
end
