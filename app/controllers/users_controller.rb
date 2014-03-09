class UsersController < ApplicationController
  layout 'no_school'

  def new
  end

  def show
    @user = User.find(params[:id])

    return redirect_to root_path unless @user == @current_user
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      flash[:message] = 'You have signed up!'
      redirect_to root_path
    else
      flash[:error] = @user.errors.full_messages.first
      redirect_to new_user_path
    end
  end

  def login
    if request.post?
      u = User.authenticate(params[:email], params[:password])
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

private

  def user_params
    params.fetch(:user, {}).permit(:email, :password, :password_confirmation)
  end
end
