class HomeController < ApplicationController
  def index
    if not @team.nil? # If logged in...
      breadcrumbs.add("Welcome!")
      render :signup # Render app/views/home/signup.html.haml
    else
      render :login  # app/views/home/login.html.haml
    end
  end

end
