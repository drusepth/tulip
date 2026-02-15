require "test_helper"

class BucketListItemTest < ActiveSupport::TestCase
  setup do
    @stay = stays(:one)
    @bucket_list_item = BucketListItem.new(
      stay: @stay,
      title: "Try surfing",
      category: "activity"
    )
  end

  test "valid bucket list item" do
    assert @bucket_list_item.valid?
  end

  test "requires title or address" do
    @bucket_list_item.title = nil
    @bucket_list_item.address = nil
    assert_not @bucket_list_item.valid?
    assert_includes @bucket_list_item.errors[:base], "Title or address must be provided"
  end

  test "valid with only address" do
    item = BucketListItem.new(stay: @stay, address: "123 Main St", category: "other")
    assert item.valid?
    assert_equal "123 Main St", item.title  # title is set from address
  end

  test "requires valid category" do
    @bucket_list_item.category = "invalid_category"
    assert_not @bucket_list_item.valid?
    assert_includes @bucket_list_item.errors[:category], "is not included in the list"
  end

  test "accepts all valid categories" do
    BucketListItem::CATEGORIES.each do |category|
      @bucket_list_item.category = category
      assert @bucket_list_item.valid?, "#{category} should be valid"
    end
  end

  test "toggle_completed! marks item as completed" do
    @bucket_list_item.save!
    assert_not @bucket_list_item.completed?
    assert_nil @bucket_list_item.completed_at

    @bucket_list_item.toggle_completed!

    assert @bucket_list_item.completed?
    assert_not_nil @bucket_list_item.completed_at
  end

  test "toggle_completed! marks completed item as pending" do
    @bucket_list_item.completed = true
    @bucket_list_item.completed_at = Time.current
    @bucket_list_item.save!

    @bucket_list_item.toggle_completed!

    assert_not @bucket_list_item.completed?
    assert_nil @bucket_list_item.completed_at
  end

  test "pending scope returns only pending items" do
    @bucket_list_item.save!
    completed_item = BucketListItem.create!(
      stay: @stay,
      title: "Completed task",
      category: "other",
      completed: true,
      completed_at: Time.current
    )

    pending_items = @stay.bucket_list_items.pending
    assert_includes pending_items, @bucket_list_item
    assert_not_includes pending_items, completed_item
  end

  test "completed scope returns only completed items" do
    @bucket_list_item.save!
    completed_item = BucketListItem.create!(
      stay: @stay,
      title: "Completed task",
      category: "other",
      completed: true,
      completed_at: Time.current
    )

    completed_items = @stay.bucket_list_items.completed
    assert_not_includes completed_items, @bucket_list_item
    assert_includes completed_items, completed_item
  end

  test "with_location scope returns items with coordinates" do
    @bucket_list_item.save!
    item_with_location = BucketListItem.create!(
      stay: @stay,
      title: "Golden Gate Bridge",
      category: "landmark",
      latitude: 37.8199,
      longitude: -122.4783
    )

    with_location = @stay.bucket_list_items.with_location
    assert_not_includes with_location, @bucket_list_item
    assert_includes with_location, item_with_location
  end

  test "has_location? returns true when coordinates present" do
    @bucket_list_item.latitude = 37.8199
    @bucket_list_item.longitude = -122.4783
    assert @bucket_list_item.has_location?
  end

  test "has_location? returns false when coordinates missing" do
    assert_not @bucket_list_item.has_location?
  end

  test "coordinates returns lat/lng array when present" do
    @bucket_list_item.latitude = 37.8199
    @bucket_list_item.longitude = -122.4783
    assert_equal [ 37.8199, -122.4783 ], @bucket_list_item.coordinates
  end

  test "coordinates returns nil when missing" do
    assert_nil @bucket_list_item.coordinates
  end

  test "defaults to other category" do
    item = BucketListItem.new(stay: @stay, title: "Test")
    assert_equal "other", item.category
  end

  test "defaults to not completed" do
    item = BucketListItem.new(stay: @stay, title: "Test")
    assert_not item.completed?
  end
end
