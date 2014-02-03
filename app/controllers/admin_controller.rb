class AdminController < ApplicationController
  before_filter :is_admin

  def index
    breadcrumbs.add("Admin Panel")
    @teams = @current_tournament.teams

    @signups = SignUp.all
    @num_signups = @signups.length
    @team_signups = @signups.map{|x| x.team.name}.uniq
    @num_team_signups = @team_signups.length
  end

  def events
    breadcrumbs.add("Events")
    @right_hidden = true
    @events = @current_tournament.schedules.includes(timeslots: :sign_ups)
    @teams_by_division = @current_tournament.divisions.inject({}) {|a,i|
      a.merge(i[0] => Team.count(:conditions=>["division = ? AND tournament_id = ?", i[0], @current_tournament]))
    }
    @event_signups = @events.inject({}){|a,i|
      a.merge(i.id => i.timeslots.map{|x| x.sign_ups.length}.sum )
    }
    @event_capacity = @events.inject({}){ |a,i|
      a.merge(i.id => i.timeslots.map{|x| x.team_capacity - x.sign_ups.length}.sum)
    }
  end

  def scores
    breadcrumbs.add("Scoring")

    @events = @current_tournament.schedules.includes(:scores)
  end

  def scoreslideshow
    breadcrumbs.add("Scoring", admin_scores_url)
    breadcrumbs.add("Slideshow")
    @teams = @current_tournament.teams
    @events = @current_tournament.schedules.includes(:scores)
    @unfinishedevents = @events.select{|x| x.scores.empty?}
    @withheldevents = @events.select{|x| x.scores_withheld?}
  end

  def scorespublish
    @events = @current_tournament.schedules.includes(:scores)
    @unfinishedevents = @events.select{|x| x.scores.empty?}
    @withheldevents = @events.select{|x| x.scores_withheld?}
  end
end
