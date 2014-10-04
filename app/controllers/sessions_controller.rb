class SessionsController < ApplicationController
  def create
    u = User.authenticate(params[:email], params[:password])

    unless u
      flash[:error] = "Invalid Email or Password"
      return redirect_to login_users_path
    end

    session[:user_id] = u.id

    if params[:next_path] && params[:next_path] !~ /\/\//
      redirect_to params[:next_path]
    elsif @current_school && u.administrates?(@current_school)
      redirect_to admin_index_url
    else
      redirect_to root_path
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to :root
  end
end
