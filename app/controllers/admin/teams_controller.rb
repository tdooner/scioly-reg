class Admin::TeamsController < ApplicationController
  before_filter :is_admin

  def index
    @teams = @current_tournament.teams.includes(:tournament)

    breadcrumbs.add("Teams")
  end

  def new
    breadcrumbs.add("Create Team")
    @this_team = Team.new
  end

  def batchnew
    breadcrumbs.add("Create Team", new_team_url)
    breadcrumbs.add("Batch Mode")
  end

  def batchcreate
    @teams, @errors = parse_teams_from_batch

    @teams.each do |team|
      if team.save
        if params[:send_email].present? && team.email.present?
          TeamMailer.password_update(team, team.password).deliver
        end
      else
        @errors << "Error with #{team.name}: #{team.errors.full_messages.first}"
      end
    end

    flash[:error] = @errors.join("<br />") unless @errors.empty?

    if not flash[:error]
      redirect_to teams_url
    else
      render :batchnew
    end
  end

  def batchpreview
    return unless request.xhr?
    @teams, @errors = parse_teams_from_batch

    render layout: false
  end

  def destroy
    @team = Team.find(params[:id])

    unless @current_admin.is_admin_of(@team.tournament.school)
      flash[:error] = 'Unauthorized!'
      return redirect_to root_url
    end

    if @team.destroy
      flash[:message] = 'Team deleted!'
    else
      flash[:error] = 'Could not delete team!'
    end

    redirect_to teams_url
  end

  def create
    @this_team = Team.new(params.fetch(:team, {}).permit(:name, :coach, :email,
                                                         :password, :division,
                                                         :number))
    @this_team.tournament = @current_tournament
    if @this_team.save
        flash[:message] = "Done!"

        if params[:send_email].present?
          TeamMailer.password_update(@this_team, params[:team][:password]).deliver
        end

        redirect_to :teams
    else
        flash[:error] = "Error: #{@this_team.errors.full_messages.first}"

        render :new
    end

  end

private

  def parse_teams_from_batch
    return [[], ['No teams specified!']] unless params[:batch].present?

    lines = params[:batch].split("\n")
    errors = []
    team_numbers = @current_tournament.teams.pluck(:number)
    team_names = @current_tournament.teams.pluck(:name)

    teams = lines.map do |t|
      a = t.strip.split("\t")

      if a.length < 7
        errors << "Short record found: #{a[0]}!"
        next
      end

      if team_names.include?(a[0])
        errors << "Duplicate team name: #{a[0]}"
      end

      if team_numbers.include?(a[1])
        errors << "Duplicate team number for team #{a[0]}"
      end

      team_names << a[0]
      team_numbers << a[1]

      @current_tournament.teams.new(
        :name => a[0],
        :number => a[1],
        :coach => a[2],
        :email => a[3],
        :division => a[4],
        :homeroom => a[5],
        :password => a[6],
      )
    end

    [teams, errors]
  end
end
