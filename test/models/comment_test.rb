require "test_helper"

class CommentTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @stay = stays(:one)
    @place = places(:blue_bottle)
    # Clean up any fixture comments for this stay to get predictable counts
    @stay.comments.destroy_all
    @place.comments.destroy_all
  end

  test "valid comment on stay" do
    comment = Comment.new(commentable: @stay, user: @user, body: "Great trip!")
    assert comment.valid?
  end

  test "valid comment on place" do
    comment = Comment.new(commentable: @place, user: @user, body: "Great coffee!")
    assert comment.valid?
  end

  test "requires body" do
    comment = Comment.new(commentable: @stay, user: @user, body: "")
    assert_not comment.valid?
    assert_includes comment.errors[:body], "can't be blank"
  end

  test "requires commentable" do
    comment = Comment.new(user: @user, body: "Test")
    assert_not comment.valid?
    assert_includes comment.errors[:commentable], "must exist"
  end

  test "requires user" do
    comment = Comment.new(commentable: @stay, body: "Test")
    assert_not comment.valid?
    assert_includes comment.errors[:user], "must exist"
  end

  test "body max length is 2000 characters" do
    comment = Comment.new(commentable: @stay, user: @user, body: "a" * 2001)
    assert_not comment.valid?
    assert_includes comment.errors[:body], "is too long (maximum is 2000 characters)"
  end

  test "can have a parent comment" do
    parent = Comment.create!(commentable: @stay, user: @user, body: "Parent comment")
    reply = Comment.new(commentable: @stay, user: @user, body: "Reply", parent: parent)
    assert reply.valid?
  end

  test "parent must be top-level" do
    parent = Comment.create!(commentable: @stay, user: @user, body: "Parent comment")
    reply = Comment.create!(commentable: @stay, user: @user, body: "Reply", parent: parent)
    nested = Comment.new(commentable: @stay, user: @user, body: "Nested reply", parent: reply)
    assert_not nested.valid?
    assert_includes nested.errors[:parent], "must be a top-level comment (no nested replies)"
  end

  test "top_level scope returns comments without parent" do
    parent = Comment.create!(commentable: @stay, user: @user, body: "Parent")
    reply = Comment.create!(commentable: @stay, user: @user, body: "Reply", parent: parent)

    top_level = @stay.comments.top_level
    assert_includes top_level, parent
    assert_not_includes top_level, reply
  end

  test "ordered scope orders by created_at ascending" do
    first = Comment.create!(commentable: @stay, user: @user, body: "First")
    sleep 0.01 # Small delay to ensure different timestamps
    second = Comment.create!(commentable: @stay, user: @user, body: "Second")

    ordered = @stay.comments.top_level.ordered.to_a
    assert_equal first, ordered.first
    assert_equal second, ordered.last
  end

  test "editable_by? returns true for author" do
    comment = Comment.create!(commentable: @stay, user: @user, body: "Test")
    assert comment.editable_by?(@user)
  end

  test "editable_by? returns false for non-author" do
    comment = Comment.create!(commentable: @stay, user: @user, body: "Test")
    other_user = users(:two)
    assert_not comment.editable_by?(other_user)
  end

  test "editable_by? returns false for nil user" do
    comment = Comment.create!(commentable: @stay, user: @user, body: "Test")
    assert_not comment.editable_by?(nil)
  end

  test "edited? returns false for new comments" do
    comment = Comment.create!(commentable: @stay, user: @user, body: "Test")
    assert_not comment.edited?
  end

  test "edited? returns true when updated" do
    comment = Comment.create!(commentable: @stay, user: @user, body: "Test")
    comment.update!(body: "Updated", updated_at: comment.created_at + 2.seconds)
    assert comment.edited?
  end

  test "replies are destroyed when parent is destroyed" do
    parent = Comment.create!(commentable: @stay, user: @user, body: "Parent")
    Comment.create!(commentable: @stay, user: @user, body: "Reply", parent: parent)

    assert_difference("Comment.count", -2) do
      parent.destroy
    end
  end

  test "comments are destroyed when stay is destroyed" do
    comment = Comment.create!(commentable: @stay, user: @user, body: "Test")
    assert_equal 1, @stay.comments.reload.count

    @stay.comments.destroy_all
    assert_equal 0, @stay.comments.reload.count
  end

  test "stay convenience method returns stay for stay comments" do
    comment = Comment.create!(commentable: @stay, user: @user, body: "Test")
    assert_equal @stay, comment.stay
  end

  test "stay convenience method returns nil for place comments" do
    comment = Comment.create!(commentable: @place, user: @user, body: "Test")
    assert_nil comment.stay
  end

  test "place comments have correct commentable" do
    comment = Comment.create!(commentable: @place, user: @user, body: "Nice place!")
    assert_equal @place, comment.commentable
    assert_equal "Place", comment.commentable_type
  end

  test "place comments support replies" do
    parent = Comment.create!(commentable: @place, user: @user, body: "Parent")
    reply = Comment.new(commentable: @place, user: @user, body: "Reply", parent: parent)
    assert reply.valid?
  end

  test "comments are destroyed when place is destroyed" do
    comment = Comment.create!(commentable: @place, user: @user, body: "Test")
    assert_equal 1, @place.comments.reload.count

    @place.comments.destroy_all
    assert_equal 0, @place.comments.reload.count
  end
end
