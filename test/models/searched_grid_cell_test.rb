require "test_helper"

class SearchedGridCellTest < ActiveSupport::TestCase
  test "mark_searched! creates a new record" do
    grid_key = "coffee:45.52:-122.67"

    assert_difference "SearchedGridCell.count", 1 do
      SearchedGridCell.mark_searched!(grid_key, category: "coffee")
    end

    cell = SearchedGridCell.find_by(grid_key: grid_key)
    assert_not_nil cell
    assert_equal "coffee", cell.category
    assert_not_nil cell.searched_at
  end

  test "mark_searched! updates existing record" do
    grid_key = "coffee:45.52:-122.67"
    old_time = 2.weeks.ago

    SearchedGridCell.create!(grid_key: grid_key, category: "coffee", searched_at: old_time)

    assert_no_difference "SearchedGridCell.count" do
      SearchedGridCell.mark_searched!(grid_key, category: "coffee")
    end

    cell = SearchedGridCell.find_by(grid_key: grid_key)
    assert cell.searched_at > old_time
  end

  test "fresh_cache? returns true for recently searched grid" do
    grid_key = "coffee:45.52:-122.67"
    SearchedGridCell.create!(grid_key: grid_key, category: "coffee", searched_at: 1.hour.ago)

    assert SearchedGridCell.fresh_cache?(grid_key)
  end

  test "fresh_cache? returns false for stale grid" do
    grid_key = "coffee:45.52:-122.67"
    SearchedGridCell.create!(grid_key: grid_key, category: "coffee", searched_at: 4.months.ago)

    assert_not SearchedGridCell.fresh_cache?(grid_key)
  end

  test "fresh_cache? returns false for unsearched grid" do
    assert_not SearchedGridCell.fresh_cache?("nonexistent:45.52:-122.67")
  end

  test "stale? returns true when searched_at is older than STALE_AFTER" do
    cell = SearchedGridCell.new(searched_at: 4.months.ago)
    assert cell.stale?
  end

  test "stale? returns false when searched_at is recent" do
    cell = SearchedGridCell.new(searched_at: 1.hour.ago)
    assert_not cell.stale?
  end

  test "fresh scope returns only fresh records" do
    fresh_key = "coffee:45.52:-122.67"
    stale_key = "coffee:45.53:-122.68"

    SearchedGridCell.create!(grid_key: fresh_key, category: "coffee", searched_at: 1.hour.ago)
    SearchedGridCell.create!(grid_key: stale_key, category: "coffee", searched_at: 4.months.ago)

    fresh_records = SearchedGridCell.fresh
    assert_includes fresh_records.pluck(:grid_key), fresh_key
    assert_not_includes fresh_records.pluck(:grid_key), stale_key
  end

  test "stale scope returns only stale records" do
    fresh_key = "coffee:45.52:-122.67"
    stale_key = "coffee:45.53:-122.68"

    SearchedGridCell.create!(grid_key: fresh_key, category: "coffee", searched_at: 1.hour.ago)
    SearchedGridCell.create!(grid_key: stale_key, category: "coffee", searched_at: 4.months.ago)

    stale_records = SearchedGridCell.stale
    assert_includes stale_records.pluck(:grid_key), stale_key
    assert_not_includes stale_records.pluck(:grid_key), fresh_key
  end
end
