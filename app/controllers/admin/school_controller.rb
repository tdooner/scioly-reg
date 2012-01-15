class Admin::SchoolController < ApplicationController
  before_filter :is_admin

  def edit
    breadcrumbs.add("Edit School Information")
  end

  def update
    if User.authenticate(@current_school, session[:user][:email], params[:current_password]) != session[:user]
      # Note that if both User.authenticate and session[:user] are nil, then the user will be redirected home
      # by the is_admin before_filter.
      flash[:error] = "Incorrect Password!"
      return redirect_to admin_school_edit_url
    end
    allowed = [:admin_name, :admin_email, :logo]
    theattr = params[:school].keep_if{|k,v| allowed.include?(k.to_sym)}
    @current_school.update_attributes( theattr )
    flash[:error] = @current_school.errors.full_messages.first
    redirect_to admin_school_edit_url
  end

end
