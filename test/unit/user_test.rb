require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @current_school = FactoryGirl.create(:school)
    @user = FactoryGirl.create(:user, :school => @current_school)
  end

  test "User is valid iff password equals password_confirmation" do
    # Initially, both are unset, so it's valid
    assert @user.valid?
    @user.password = "abcedf"
    @user.password_confirmation = "ghijkl"
    assert !@user.valid?
    @user.password = "abcedf"
    @user.password_confirmation = "abcedf"
    assert @user.valid?
  end

  test "User is an admin of the school it was created under" do
    assert @user.is_admin_of(@current_school)
  end

  test "User authenticates successfully." do
    user = FactoryGirl.build(:user, :school => @current_school)
    user.password = "password"
    user.password_confirmation = "password"
    assert user.save
    assert user == User.authenticate(@current_school, user.email, "password")
  end

  test "User can change password successfully." do
    hash = @user.hashed_password
    @user.password = "new_password"
    @user.password_confirmation = "new_password"
    assert @user.save
    assert @user.reload.hashed_password != hash
  end

end
