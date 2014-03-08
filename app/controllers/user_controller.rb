class UserController < ApplicationController
  layout 'no_school'

  def login
    if request.post?
      u = User.authenticate(@current_school, params[:email], params[:password])
      if u.nil?
        flash[:error] = "Invalid Email or Password"
      else
        session[:user_id] = u.id
        return redirect_to admin_index_url
      end
    end
  end

  def logout
    session.delete(:user_id)
    redirect_to :root
  end
end
