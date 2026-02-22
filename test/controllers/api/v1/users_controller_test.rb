require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @token = create_api_token(@user)
  end

  # Helper to create a valid API token for testing
  def create_api_token(user)
    Devise::Api::Token.create!(
      resource_owner: user,
      access_token: SecureRandom.hex(32),
      refresh_token: SecureRandom.hex(32),
      expires_in: 1.hour.to_i
    )
  end

  def auth_headers
    { "Authorization" => "Bearer #{@token.access_token}" }
  end

  # Password Change Tests
  test "update_password succeeds with correct current password" do
    patch api_v1_profile_password_path,
      params: {
        current_password: "password123",
        password: "newpassword456",
        password_confirmation: "newpassword456"
      },
      headers: auth_headers,
      as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Password updated successfully", json["message"]

    # Verify the password was actually changed
    @user.reload
    assert @user.valid_password?("newpassword456")
  end

  test "update_password fails with incorrect current password" do
    patch api_v1_profile_password_path,
      params: {
        current_password: "wrongpassword",
        password: "newpassword456",
        password_confirmation: "newpassword456"
      },
      headers: auth_headers,
      as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "Current password is incorrect", json["error"]

    # Verify the password was not changed
    @user.reload
    assert @user.valid_password?("password123")
  end

  test "update_password fails when passwords do not match" do
    patch api_v1_profile_password_path,
      params: {
        current_password: "password123",
        password: "newpassword456",
        password_confirmation: "differentpassword"
      },
      headers: auth_headers,
      as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json["errors"], "Password confirmation doesn't match Password"

    # Verify the password was not changed
    @user.reload
    assert @user.valid_password?("password123")
  end

  test "update_password fails with too short password" do
    patch api_v1_profile_password_path,
      params: {
        current_password: "password123",
        password: "short",
        password_confirmation: "short"
      },
      headers: auth_headers,
      as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].any? { |e| e.include?("too short") }
  end

  test "update_password requires authentication" do
    patch api_v1_profile_password_path,
      params: {
        current_password: "password123",
        password: "newpassword456",
        password_confirmation: "newpassword456"
      },
      as: :json

    assert_response :unauthorized
  end

  # Account Deletion Tests
  test "destroy succeeds with correct password" do
    user_id = @user.id

    assert_difference("User.count", -1) do
      delete api_v1_profile_path,
        params: { current_password: "password123" },
        headers: auth_headers,
        as: :json
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Account deleted successfully", json["message"]

    # Verify user no longer exists
    assert_nil User.find_by(id: user_id)
  end

  test "destroy fails with incorrect password" do
    assert_no_difference("User.count") do
      delete api_v1_profile_path,
        params: { current_password: "wrongpassword" },
        headers: auth_headers,
        as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "Current password is incorrect", json["error"]
  end

  test "destroy requires authentication" do
    assert_no_difference("User.count") do
      delete api_v1_profile_path,
        params: { current_password: "password123" },
        as: :json
    end

    assert_response :unauthorized
  end

  test "destroy deletes associated stays" do
    # Create a stay for the user
    stay = Stay.create!(
      user: @user,
      title: "Test Stay",
      city: "Portland"
    )

    # Count stays owned by this user before deletion
    user_stay_count = @user.stays.count
    assert user_stay_count >= 1, "User should have at least one stay"

    delete api_v1_profile_path,
      params: { current_password: "password123" },
      headers: auth_headers,
      as: :json

    assert_response :success
    # Verify the newly created stay is deleted
    assert_nil Stay.find_by(id: stay.id)
    # Verify no stays remain for this user
    assert_equal 0, Stay.where(user_id: @user.id).count
  end

  # Profile Show/Update Tests (existing functionality)
  test "show returns current user profile" do
    get api_v1_profile_path, headers: auth_headers, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @user.id, json["id"]
    assert_equal @user.email, json["email"]
  end

  test "update modifies user profile" do
    patch api_v1_profile_path,
      params: { display_name: "New Name" },
      headers: auth_headers,
      as: :json

    assert_response :success
    @user.reload
    assert_equal "New Name", @user.display_name
  end
end
