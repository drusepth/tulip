require "test_helper"

class StayCollaborationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user_one = users(:one)
    @user_two = users(:two)
    @stay_one = stays(:one)
    @stay_two = stays(:two)
    @pending_invite = stay_collaborations(:pending_invite)
    @accepted_collaboration = stay_collaborations(:accepted_collaboration)
  end

  # Index tests
  test "owner can view collaborations page" do
    sign_in @user_one
    get stay_collaborations_path(@stay_one)
    assert_response :success
  end

  test "collaborator cannot view collaborations page" do
    sign_in @user_two
    get stay_collaborations_path(@stay_one)
    # Should redirect because they're not the owner
    assert_redirected_to stay_path(@stay_one)
  end

  # Create invite tests
  test "owner can create invite link" do
    sign_in @user_one
    assert_difference("StayCollaboration.count", 1) do
      post stay_collaborations_path(@stay_one), params: { role: "editor" }
    end
    assert_redirected_to stay_collaborations_path(@stay_one)
  end

  test "collaborator cannot create invite link" do
    sign_in @user_two
    assert_no_difference("StayCollaboration.count") do
      post stay_collaborations_path(@stay_one), params: { role: "editor" }
    end
    assert_redirected_to stay_path(@stay_one)
  end

  # Delete collaboration tests
  test "owner can remove collaborator" do
    sign_in @user_one
    assert_difference("StayCollaboration.count", -1) do
      delete stay_collaboration_path(@stay_one, @accepted_collaboration)
    end
    assert_redirected_to stay_collaborations_path(@stay_one)
  end

  test "owner can cancel pending invite" do
    sign_in @user_one
    assert_difference("StayCollaboration.count", -1) do
      delete stay_collaboration_path(@stay_two, @pending_invite)
    end
  end

  # Accept invite tests
  test "logged in user can accept invite" do
    new_user = User.create!(email: "new@example.com", password: "password123")
    sign_in new_user

    get accept_invite_path(@pending_invite.invite_token)
    assert_redirected_to stay_path(@stay_two)

    @pending_invite.reload
    assert_equal new_user, @pending_invite.user
    assert @pending_invite.invite_accepted_at.present?
  end

  test "anonymous user is redirected to sign in" do
    get accept_invite_path(@pending_invite.invite_token)
    assert_redirected_to new_user_session_path
  end

  test "invalid token shows error" do
    sign_in @user_one
    get accept_invite_path("invalid_token")
    assert_redirected_to root_path
    assert_match /invalid/i, flash[:alert]
  end

  test "already accepted invite shows message" do
    sign_in @user_two  # This user already accepted the invite
    get accept_invite_path(@accepted_collaboration.invite_token)
    assert_redirected_to stay_path(@stay_one)
  end

  # Leave tests
  test "collaborator can leave stay" do
    sign_in @user_two
    assert_difference("StayCollaboration.count", -1) do
      delete leave_stay_collaborations_path(@stay_one)
    end
    assert_redirected_to root_path
  end

  test "owner cannot leave their own stay" do
    sign_in @user_one
    assert_no_difference("StayCollaboration.count") do
      delete leave_stay_collaborations_path(@stay_one)
    end
    assert_redirected_to stay_path(@stay_one)
    assert_match /owner/i, flash[:alert]
  end
end
