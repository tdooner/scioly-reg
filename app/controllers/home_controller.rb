class HomeController < ApplicationController
  def index
	  if not session[:team].nil? # If logged in...
		  render :signup # Render app/views/home/signup.html.haml
	  else
		  render :login # app/views/home/login.html.haml
	  end
  end

end
