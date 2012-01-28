class HomeController < ApplicationController
  def index
      render :login # app/views/home/login.html.haml
  end

  def team_home
      return redirect_to root_url unless @team
      breadcrumbs.add("Welcome!")
      render :signup # Render app/views/home/signup.html.haml
  end
end
