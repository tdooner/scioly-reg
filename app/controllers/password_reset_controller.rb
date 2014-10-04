class PasswordResetController < ApplicationController
  before_action :set_user, only: [:choose_password, :set_new_password]
  before_action :verify_reset_token, only: [:choose_password, :set_new_password]

  def new
  end

  def create
    @found_user = User.find_by(email: params[:email])

    unless @found_user
      flash[:error] = "We don't have an account at that address."
      return redirect_to login_users_path
    end

    @reset_token = @found_user.set_reset_token!

    UserMailer.forgot_password(user: @found_user, reset_token: @reset_token).deliver
  end

  def choose_password
  end

  def set_new_password
    attributes = params.permit(:password, :password_confirmation)
    attributes[:reset_token] = nil
    attributes[:reset_token_sent_at] = nil

    if @found_user.update_attributes(attributes)
      flash[:message] = "Password successfully updated."
    else
      flash[:error] = "Error, we could not update your password! Please email tomdooner@gmail.com if it is time sensitive."
    end

    return redirect_to login_users_path
  end

  private

  def set_user
    @found_user = User.find(params[:user_id])
  end

  def verify_reset_token
    if @found_user.reset_token.blank? || @found_user.reset_token_sent_at.blank? || @found_user.reset_token != params[:reset_token]
      flash[:error] = "Sorry, we're experiencing an error and can't reset your password right now. Please email tomdooner@gmail.com if this is time-sensitive."
      return redirect_to login_users_path
    end

    if @found_user.reset_token_sent_at < 1.hour.ago
      flash[:error] = "Password reset expired. Please click 'Forgot Password' again."
      redirect_to login_users_path
    end
  end
end
