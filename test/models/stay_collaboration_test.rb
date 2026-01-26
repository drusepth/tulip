require "test_helper"

class StayCollaborationTest < ActiveSupport::TestCase
  def setup
    @user_one = users(:one)
    @user_two = users(:two)
    @stay_one = stays(:one)
    @stay_two = stays(:two)
  end

  test "valid collaboration" do
    collaboration = StayCollaboration.new(
      stay: @stay_two,
      user: @user_two,
      role: "editor",
      invite_accepted_at: Time.current
    )
    assert collaboration.valid?
  end

  test "requires valid role" do
    collaboration = StayCollaboration.new(
      stay: @stay_two,
      role: "invalid_role"
    )
    assert_not collaboration.valid?
    assert collaboration.errors[:role].present?
  end

  test "generates invite token on create when not accepted" do
    collaboration = StayCollaboration.new(
      stay: @stay_two,
      role: "editor"
    )
    collaboration.save!
    assert collaboration.invite_token.present?
  end

  test "does not allow duplicate user-stay combinations" do
    # First collaboration exists via fixture
    duplicate = StayCollaboration.new(
      stay: @stay_one,
      user: @user_two,
      role: "editor",
      invite_accepted_at: Time.current
    )
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].present?
  end

  test "pending? returns true when invite not accepted" do
    collaboration = stay_collaborations(:pending_invite)
    assert collaboration.pending?
  end

  test "pending? returns false when invite accepted" do
    collaboration = stay_collaborations(:accepted_collaboration)
    assert_not collaboration.pending?
  end

  test "accept! assigns user and sets accepted timestamp" do
    collaboration = stay_collaborations(:pending_invite)
    new_user = User.create!(email: "new@example.com", password: "password123")

    assert collaboration.accept!(new_user)
    assert_equal new_user, collaboration.user
    assert collaboration.invite_accepted_at.present?
  end

  test "accept! fails if already accepted" do
    collaboration = stay_collaborations(:accepted_collaboration)
    new_user = User.create!(email: "new@example.com", password: "password123")

    assert_not collaboration.accept!(new_user)
  end

  test "accept! fails if user already has access" do
    collaboration = stay_collaborations(:pending_invite)
    # User one owns the stay
    assert_not collaboration.accept!(@user_one)
  end

  test "scopes return correct collaborations" do
    pending_count = StayCollaboration.pending.count
    accepted_count = StayCollaboration.accepted.count

    assert pending_count >= 1
    assert accepted_count >= 1
  end
end
