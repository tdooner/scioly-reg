class AdminController < ApplicationController
	before_filter :is_admin

  def index
	  breadcrumbs.add("Admin Panel")
	  @signups = SignUp.all
	  @num_signups = @signups.length
	  @team_signups = @signups.map{|x| x.team.name}.uniq
	  @num_team_signups = @team_signups.length
  end
end
