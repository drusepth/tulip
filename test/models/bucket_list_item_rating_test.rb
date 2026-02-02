require "test_helper"

class BucketListItemRatingTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @stay = stays(:one)
    @bucket_list_item = @stay.bucket_list_items.create!(
      title: "Test Item",
      category: "restaurant",
      completed: true,
      completed_at: Time.current
    )
  end

  test "valid rating" do
    rating = BucketListItemRating.new(
      bucket_list_item: @bucket_list_item,
      user: @user,
      rating: 4
    )
    assert rating.valid?
  end

  test "rating must be between 1 and 5" do
    rating = BucketListItemRating.new(
      bucket_list_item: @bucket_list_item,
      user: @user,
      rating: 0
    )
    assert_not rating.valid?
    assert_includes rating.errors[:rating], "is not included in the list"

    rating.rating = 6
    assert_not rating.valid?
    assert_includes rating.errors[:rating], "is not included in the list"

    rating.rating = 3
    assert rating.valid?
  end

  test "user can only rate item once" do
    BucketListItemRating.create!(
      bucket_list_item: @bucket_list_item,
      user: @user,
      rating: 4
    )

    duplicate = BucketListItemRating.new(
      bucket_list_item: @bucket_list_item,
      user: @user,
      rating: 5
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already rated this item"
  end

  test "cannot rate incomplete item" do
    incomplete_item = @stay.bucket_list_items.create!(
      title: "Incomplete Item",
      category: "activity",
      completed: false
    )

    rating = BucketListItemRating.new(
      bucket_list_item: incomplete_item,
      user: @user,
      rating: 3
    )
    assert_not rating.valid?
    assert_includes rating.errors[:base], "Cannot rate an incomplete bucket list item"
  end

  test "bucket_list_item has rating_for method" do
    BucketListItemRating.create!(
      bucket_list_item: @bucket_list_item,
      user: @user,
      rating: 4
    )

    rating = @bucket_list_item.rating_for(@user)
    assert_not_nil rating
    assert_equal 4, rating.rating

    other_user = users(:two)
    assert_nil @bucket_list_item.rating_for(other_user)
  end
end
