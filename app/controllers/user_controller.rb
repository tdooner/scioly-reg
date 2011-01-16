class UserController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter

  def login
	  @u = User.find(:first, :conditions => ["caseid = ?",session[:cas_user]])
	  if @u
		  session[:user] = @u
		  redirect_to :root
	  else
		  flash[:error] = "Invalid Login!"
		  redirect_to :root
	  end
  end
end
