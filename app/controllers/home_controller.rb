class HomeController < ApplicationController
  def index
      render :login # app/views/home/login.html.haml
  end

  def team_home
      breadcrumbs.add("Welcome!")
      render :signup # Render app/views/home/signup.html.haml
  end
end
