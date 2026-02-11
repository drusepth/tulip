require "test_helper"

class PlaceCommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    sign_in @user
    @place = places(:blue_bottle)
    @place.comments.destroy_all # Clean up fixture comments
    @comment = Comment.create!(
      commentable: @place,
      user: @user,
      body: "This is a test place comment"
    )
  end

  test "should create comment on place" do
    assert_difference("Comment.count") do
      post place_comments_path(@place), params: {
        comment: { body: "New place comment" }
      }
    end

    assert_redirected_to place_path(@place)
    comment = Comment.last
    assert_equal "Place", comment.commentable_type
    assert_equal @place.id, comment.commentable_id
  end

  test "should create comment on place with turbo stream" do
    assert_difference("Comment.count") do
      post place_comments_path(@place), params: {
        comment: { body: "New place comment" }
      }, as: :turbo_stream
    end

    assert_response :success
  end

  test "should create reply to place comment" do
    assert_difference("Comment.count") do
      post place_comments_path(@place), params: {
        comment: { body: "Reply to place comment", parent_id: @comment.id }
      }
    end

    reply = Comment.last
    assert_equal @comment.id, reply.parent_id
    assert_equal "Place", reply.commentable_type
  end

  test "should not create place comment without body" do
    assert_no_difference("Comment.count") do
      post place_comments_path(@place), params: {
        comment: { body: "" }
      }
    end
  end

  test "should get edit as turbo stream" do
    get edit_place_comment_path(@place, @comment), as: :turbo_stream
    assert_response :success
  end

  test "should not get edit for other user's comment" do
    sign_out @user
    sign_in @other_user

    get edit_place_comment_path(@place, @comment), as: :turbo_stream
    assert_response :forbidden
  end

  test "should update place comment" do
    patch place_comment_path(@place, @comment), params: {
      comment: { body: "Updated place comment" }
    }

    assert_redirected_to place_path(@place)
    @comment.reload
    assert_equal "Updated place comment", @comment.body
  end

  test "should update place comment with turbo stream" do
    patch place_comment_path(@place, @comment), params: {
      comment: { body: "Updated place comment" }
    }, as: :turbo_stream

    assert_response :success
    @comment.reload
    assert_equal "Updated place comment", @comment.body
  end

  test "should not update other user's place comment" do
    sign_out @user
    sign_in @other_user

    patch place_comment_path(@place, @comment), params: {
      comment: { body: "Hacked!" }
    }

    @comment.reload
    assert_equal "This is a test place comment", @comment.body
  end

  test "should destroy place comment" do
    assert_difference("Comment.count", -1) do
      delete place_comment_path(@place, @comment)
    end

    assert_redirected_to place_path(@place)
  end

  test "should destroy place comment with turbo stream" do
    assert_difference("Comment.count", -1) do
      delete place_comment_path(@place, @comment), as: :turbo_stream
    end

    assert_response :success
  end

  test "should not destroy other user's place comment" do
    sign_out @user
    sign_in @other_user

    assert_no_difference("Comment.count") do
      delete place_comment_path(@place, @comment)
    end
  end

  test "any logged-in user can comment on a place" do
    sign_out @user
    sign_in @other_user

    assert_difference("Comment.count") do
      post place_comments_path(@place), params: {
        comment: { body: "Anyone can comment on places" }
      }
    end

    assert_redirected_to place_path(@place)
  end
end
