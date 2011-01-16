class UserController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter

  def login
	  @u = User.find(:first, :conditions => ["case_id = ?",session[:cas_user]])
	  if @u
		  session[:user] = @u
		  redirect_to :admin_index
	  else
		  flash[:error] = "Invalid Login!"
		  redirect_to :root
	  end
  end

  def logout
	  session[:user] = nil
	  redirect_to :root
  end
end
