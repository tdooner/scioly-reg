class Admin::SchoolController < ApplicationController
  before_filter :is_admin

  def edit
    breadcrumbs.add("Edit School Information")
  end

  def update
    if Digest::SHA1.hexdigest(params[:school][:existing_password]) != @current_school.admin_password
      flash[:error] = "Incorrect Password!"
      return redirect_to admin_school_edit_url
    end
    if params[:school][:password] != params[:school][:password_confirm]
      flash[:error] = "New Passwords do not match!"
      return redirect_to admin_school_edit_url
    end
    if params[:school][:password].empty?
      params[:school].delete(:password)
      params[:school].delete(:password_confirm)
    end

    allowed = [:admin_name, :admin_email, :password, :password_confirm, :logo]
    theattr = params[:school].keep_if{|k,v| allowed.include?(k.to_sym)}
    @current_school.update_attributes( theattr )
    flash[:error] = @current_school.errors.full_messages.first
    redirect_to admin_school_edit_url
  end

end
