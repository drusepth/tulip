require "test_helper"

class Api::V1::TenantRightsControllerTest < ActionDispatch::IntegrationTest
  test "index returns all states without authentication" do
    get "/api/v1/tenant-rights"
    assert_response :success

    data = JSON.parse(response.body)
    assert_kind_of Array, data
    assert data.length >= 50
    assert data.first.key?("name")
    assert data.first.key?("slug")
    assert data.first.key?("summary")
  end

  test "index returns states sorted by name" do
    get "/api/v1/tenant-rights"
    data = JSON.parse(response.body)
    names = data.map { |s| s["name"] }
    assert_equal names, names.sort
  end

  test "show returns a state by slug" do
    get "/api/v1/tenant-rights/california"
    assert_response :success

    data = JSON.parse(response.body)
    assert_equal "California", data["name"]
    assert_equal "california", data["slug"]
    assert data.key?("sections")
    assert data["sections"].key?("security_deposits")
  end

  test "show returns 404 for unknown state" do
    get "/api/v1/tenant-rights/narnia"
    assert_response :not_found
  end

  test "show works for hyphenated state slugs" do
    get "/api/v1/tenant-rights/new-york"
    assert_response :success

    data = JSON.parse(response.body)
    assert_equal "New York", data["name"]
  end
end
