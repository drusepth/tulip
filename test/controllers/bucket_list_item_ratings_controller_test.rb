require "test_helper"

class BucketListItemRatingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @stay = stays(:one)
    @bucket_list_item = @stay.bucket_list_items.create!(
      title: "Test Item",
      category: "restaurant",
      completed: true,
      completed_at: Time.current
    )
    sign_in @user
  end

  test "should create rating" do
    assert_difference("BucketListItemRating.count", 1) do
      post stay_bucket_list_item_rating_path(@stay, @bucket_list_item),
           params: { rating: 4 },
           as: :turbo_stream
    end

    assert_response :success
    assert_equal 4, @bucket_list_item.rating_for(@user).rating
  end

  test "should update existing rating" do
    @bucket_list_item.ratings.create!(user: @user, rating: 3)

    assert_no_difference("BucketListItemRating.count") do
      post stay_bucket_list_item_rating_path(@stay, @bucket_list_item),
           params: { rating: 5 },
           as: :turbo_stream
    end

    assert_response :success
    assert_equal 5, @bucket_list_item.rating_for(@user).reload.rating
  end

  test "should destroy rating" do
    @bucket_list_item.ratings.create!(user: @user, rating: 4)

    assert_difference("BucketListItemRating.count", -1) do
      delete stay_bucket_list_item_rating_path(@stay, @bucket_list_item),
             as: :turbo_stream
    end

    assert_response :success
    assert_nil @bucket_list_item.rating_for(@user)
  end

  test "should not allow rating items on inaccessible stays" do
    other_user = users(:two)
    other_stay = other_user.stays.create!(
      title: "Other Stay",
      city: "Seattle",
      check_in: Date.tomorrow,
      check_out: Date.tomorrow + 3
    )
    other_item = other_stay.bucket_list_items.create!(
      title: "Other Item",
      category: "activity",
      completed: true,
      completed_at: Time.current
    )

    post stay_bucket_list_item_rating_path(other_stay, other_item),
         params: { rating: 4 }

    assert_redirected_to root_path
  end
end
