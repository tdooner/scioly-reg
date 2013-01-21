class UserController < ApplicationController

  def login
    breadcrumbs.add("Admin Login")
    if request.post?
      u = User.authenticate(@current_school, params[:email], params[:password])
      if u.nil?
        flash[:error] = "Invalid Email or Password"
      else
        session[:user] = u
        return redirect_to admin_index_url
      end
    end
  end

  def logout
    session[:user] = nil
    redirect_to :root
  end
end
