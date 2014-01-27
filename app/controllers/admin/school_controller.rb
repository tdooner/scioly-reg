class Admin::SchoolController < ApplicationController
  before_filter :is_admin

  def edit
    breadcrumbs.add("Edit School Information")

    @admins = @current_school.users
  end

  def update
    if User.authenticate(@current_school, @current_admin.email, params[:current_password]) != @current_admin
      flash[:error] = "Incorrect Password!"
      return redirect_to admin_school_edit_url
    end
    # Process all of the user deleting and new users.
    if params[:delete]
      params[:delete].each do |i|
        u = User.find(i)
        u.delete if @current_admin.can_delete?(u)
      end
    end
    if !params[:new_user].empty?
      u = @current_school.users.new({:email => params[:new_user], :password => params[:new_user_password], :password_confirmation => params[:new_user_password_confirmation], :role => 1})
      if !u.save
        flash[:error] = "Could not create user: #{u.errors.full_messages.first}"
      end
    end

    allowed = [:admin_name, :admin_email, :logo, :time_zone]
    theattr = params[:school].keep_if{|k,v| allowed.include?(k.to_sym)}
    if !@current_school.update_attributes( theattr )
      flash[:error] = @current_school.errors.full_messages.first
    end
    redirect_to admin_school_edit_url
  end

end
