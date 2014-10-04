class UsersController < ApplicationController
  layout 'no_school', only: %i[new]

  def new
  end

  def show
    return redirect_to root_path unless params[:id].to_i == @current_user.id

    @user = @current_user
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      flash[:message] = 'You have signed up!'

      if params[:next_path] && params[:next_path] !~ /\/\//
        redirect_to params[:next_path]
      else
        redirect_to root_path
      end
    else
      flash[:error] = @user.errors.full_messages.first
      redirect_to new_users_path
    end
  end

  def login
    @teams = @current_tournament.teams if @current_tournament

    if request.subdomain.blank?
      render layout: 'no_school'
    end
  end

private

  def user_params
    params.fetch(:user, {}).permit(:email, :password, :password_confirmation)
  end
end
