require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    sign_in @user
    @stay = stays(:one)
    @stay.comments.destroy_all # Clean up fixture comments
    @comment = Comment.create!(
      stay: @stay,
      user: @user,
      body: "This is a test comment"
    )
  end

  test "should create comment" do
    assert_difference("Comment.count") do
      post stay_comments_path(@stay), params: {
        comment: { body: "New comment" }
      }
    end

    assert_redirected_to stay_path(@stay)
  end

  test "should create comment with turbo stream" do
    assert_difference("Comment.count") do
      post stay_comments_path(@stay), params: {
        comment: { body: "New comment" }
      }, as: :turbo_stream
    end

    assert_response :success
  end

  test "should create reply to comment" do
    assert_difference("Comment.count") do
      post stay_comments_path(@stay), params: {
        comment: { body: "Reply comment", parent_id: @comment.id }
      }
    end

    reply = Comment.last
    assert_equal @comment.id, reply.parent_id
  end

  test "should not create comment without body" do
    assert_no_difference("Comment.count") do
      post stay_comments_path(@stay), params: {
        comment: { body: "" }
      }
    end
  end

  test "should get edit as turbo stream" do
    get edit_stay_comment_path(@stay, @comment), as: :turbo_stream
    assert_response :success
  end

  test "should not get edit for other user's comment" do
    sign_out @user
    sign_in @other_user

    get edit_stay_comment_path(@stay, @comment), as: :turbo_stream
    assert_response :forbidden
  end

  test "should update comment" do
    patch stay_comment_path(@stay, @comment), params: {
      comment: { body: "Updated comment" }
    }

    assert_redirected_to stay_path(@stay)
    @comment.reload
    assert_equal "Updated comment", @comment.body
  end

  test "should update comment with turbo stream" do
    patch stay_comment_path(@stay, @comment), params: {
      comment: { body: "Updated comment" }
    }, as: :turbo_stream

    assert_response :success
    @comment.reload
    assert_equal "Updated comment", @comment.body
  end

  test "should not update other user's comment" do
    sign_out @user
    sign_in @other_user

    patch stay_comment_path(@stay, @comment), params: {
      comment: { body: "Hacked!" }
    }

    @comment.reload
    assert_equal "This is a test comment", @comment.body
  end

  test "should destroy comment" do
    assert_difference("Comment.count", -1) do
      delete stay_comment_path(@stay, @comment)
    end

    assert_redirected_to stay_path(@stay)
  end

  test "should destroy comment with turbo stream" do
    assert_difference("Comment.count", -1) do
      delete stay_comment_path(@stay, @comment), as: :turbo_stream
    end

    assert_response :success
  end

  test "should not destroy other user's comment" do
    sign_out @user
    sign_in @other_user

    assert_no_difference("Comment.count") do
      delete stay_comment_path(@stay, @comment)
    end
  end

  test "destroying parent comment also destroys replies" do
    reply = Comment.create!(
      stay: @stay,
      user: @other_user,
      body: "This is a reply",
      parent: @comment
    )

    assert_difference("Comment.count", -2) do
      delete stay_comment_path(@stay, @comment)
    end
  end

  test "collaborator can create comment" do
    # User two is already a collaborator via fixtures
    sign_out @user
    sign_in @other_user

    assert_difference("Comment.count") do
      post stay_comments_path(@stay), params: {
        comment: { body: "Collaborator comment" }
      }
    end
  end

  test "collaborator can edit own comment" do
    # User two is already a collaborator via fixtures
    collaborator_comment = Comment.create!(
      stay: @stay,
      user: @other_user,
      body: "Collaborator's comment"
    )

    sign_out @user
    sign_in @other_user

    patch stay_comment_path(@stay, collaborator_comment), params: {
      comment: { body: "Updated by collaborator" }
    }

    collaborator_comment.reload
    assert_equal "Updated by collaborator", collaborator_comment.body
  end

  test "collaborator cannot edit owner's comment" do
    # User two is already a collaborator via fixtures
    sign_out @user
    sign_in @other_user

    patch stay_comment_path(@stay, @comment), params: {
      comment: { body: "Trying to edit owner's comment" }
    }

    @comment.reload
    assert_equal "This is a test comment", @comment.body
  end

  test "non-collaborator cannot access stay comments" do
    # Use a different stay that user two does not have access to
    @stay_two = stays(:two)

    sign_out @user
    sign_in @other_user

    post stay_comments_path(@stay_two), params: {
      comment: { body: "Unauthorized comment" }
    }

    assert_redirected_to root_path
  end
end
