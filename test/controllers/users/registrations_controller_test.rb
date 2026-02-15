require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test "can update display name without providing current password" do
    sign_in @user
    put user_registration_path, params: {
      user: {
        display_name: "New Name",
        email: @user.email,
        password: "",
        password_confirmation: "",
        current_password: ""
      }
    }
    assert_response :redirect
    @user.reload
    assert_equal "New Name", @user.display_name
  end

  test "requires current password to change email" do
    sign_in @user
    put user_registration_path, params: {
      user: {
        email: "newemail@example.com",
        password: "",
        password_confirmation: "",
        current_password: ""
      }
    }
    assert_response :unprocessable_entity
  end

  test "requires current password to change password" do
    sign_in @user
    put user_registration_path, params: {
      user: {
        email: @user.email,
        password: "newpassword123",
        password_confirmation: "newpassword123",
        current_password: ""
      }
    }
    assert_response :unprocessable_entity
  end
end
