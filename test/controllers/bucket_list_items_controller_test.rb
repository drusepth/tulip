require "test_helper"

class BucketListItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @stay = stays(:one)
    @bucket_list_item = BucketListItem.create!(
      stay: @stay,
      title: "Visit the museum",
      category: "landmark"
    )
  end

  test "should create bucket list item" do
    assert_difference("BucketListItem.count") do
      post stay_bucket_list_items_path(@stay), params: {
        bucket_list_item: {
          title: "Try surfing",
          category: "activity"
        }
      }
    end

    assert_redirected_to stay_path(@stay)
  end

  test "should create bucket list item with turbo stream" do
    assert_difference("BucketListItem.count") do
      post stay_bucket_list_items_path(@stay), params: {
        bucket_list_item: {
          title: "Try surfing",
          category: "activity"
        }
      }, as: :turbo_stream
    end

    assert_response :success
  end

  test "should not create bucket list item without title" do
    assert_no_difference("BucketListItem.count") do
      post stay_bucket_list_items_path(@stay), params: {
        bucket_list_item: {
          title: "",
          category: "activity"
        }
      }
    end
  end

  test "should get edit as turbo stream" do
    get edit_stay_bucket_list_item_path(@stay, @bucket_list_item), as: :turbo_stream
    assert_response :success
  end

  test "should update bucket list item" do
    patch stay_bucket_list_item_path(@stay, @bucket_list_item), params: {
      bucket_list_item: {
        title: "Updated title",
        category: "restaurant"
      }
    }

    assert_redirected_to stay_path(@stay)
    @bucket_list_item.reload
    assert_equal "Updated title", @bucket_list_item.title
    assert_equal "restaurant", @bucket_list_item.category
  end

  test "should update bucket list item with turbo stream" do
    patch stay_bucket_list_item_path(@stay, @bucket_list_item), params: {
      bucket_list_item: {
        title: "Updated title",
        category: "restaurant"
      }
    }, as: :turbo_stream

    assert_response :success
    @bucket_list_item.reload
    assert_equal "Updated title", @bucket_list_item.title
  end

  test "should destroy bucket list item" do
    assert_difference("BucketListItem.count", -1) do
      delete stay_bucket_list_item_path(@stay, @bucket_list_item)
    end

    assert_redirected_to stay_path(@stay)
  end

  test "should destroy bucket list item with turbo stream" do
    assert_difference("BucketListItem.count", -1) do
      delete stay_bucket_list_item_path(@stay, @bucket_list_item), as: :turbo_stream
    end

    assert_response :success
  end

  test "should toggle bucket list item from pending to completed" do
    assert_not @bucket_list_item.completed?

    patch toggle_stay_bucket_list_item_path(@stay, @bucket_list_item)

    @bucket_list_item.reload
    assert @bucket_list_item.completed?
    assert_not_nil @bucket_list_item.completed_at
  end

  test "should toggle bucket list item from completed to pending" do
    @bucket_list_item.update!(completed: true, completed_at: Time.current)

    patch toggle_stay_bucket_list_item_path(@stay, @bucket_list_item)

    @bucket_list_item.reload
    assert_not @bucket_list_item.completed?
    assert_nil @bucket_list_item.completed_at
  end

  test "should toggle with turbo stream" do
    patch toggle_stay_bucket_list_item_path(@stay, @bucket_list_item), as: :turbo_stream
    assert_response :success
  end

  test "should create bucket list item with optional fields" do
    assert_difference("BucketListItem.count") do
      post stay_bucket_list_items_path(@stay), params: {
        bucket_list_item: {
          title: "Visit Golden Gate Bridge",
          category: "landmark",
          address: "Golden Gate Bridge, San Francisco, CA",
          notes: "Best views at sunset"
        }
      }
    end

    item = BucketListItem.last
    assert_equal "Golden Gate Bridge, San Francisco, CA", item.address
    assert_equal "Best views at sunset", item.notes
  end

  test "should get map_index as json" do
    # Create a bucket list item with coordinates
    item_with_location = BucketListItem.create!(
      stay: @stay,
      title: "Coffee shop",
      category: "restaurant",
      address: "123 Main St",
      latitude: 37.7749,
      longitude: -122.4194
    )

    get api_bucket_list_items_path, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_kind_of Array, json_response

    # Should include the item with coordinates
    item_data = json_response.find { |item| item["id"] == item_with_location.id }
    assert_not_nil item_data
    assert_equal "Coffee shop", item_data["title"]
    assert_in_delta 37.7749, item_data["latitude"].to_f, 0.0001
    assert_in_delta(-122.4194, item_data["longitude"].to_f, 0.0001)
    assert_equal @stay.title, item_data["stay_title"]
  end

  test "map_index should not include items without coordinates" do
    # Create item without coordinates
    item_without_location = BucketListItem.create!(
      stay: @stay,
      title: "Something to do",
      category: "activity"
    )

    get api_bucket_list_items_path, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    item_ids = json_response.map { |item| item["id"] }
    assert_not_includes item_ids, item_without_location.id
  end
end
