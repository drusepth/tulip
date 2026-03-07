require "test_helper"

class TenantRightsControllerTest < ActionDispatch::IntegrationTest
  test "index is accessible without authentication" do
    get tenant_rights_path
    assert_response :success
    assert_select "h1", /Tenant Rights by State/
  end

  test "index lists all states" do
    get tenant_rights_path
    assert_response :success
    assert_select "h2", "California"
    assert_select "h2", "New York"
    assert_select "h2", "Texas"
  end

  test "show displays a state page without authentication" do
    get tenant_right_path(state_slug: "california")
    assert_response :success
    assert_select "h1", /California Tenant Rights/
  end

  test "show displays all sections for a state" do
    get tenant_right_path(state_slug: "california")
    assert_response :success
    assert_select "h2", "When You Become a Tenant"
    assert_select "h2", "Security Deposits"
    assert_select "h2", "Eviction Protections"
  end

  test "show redirects for unknown state" do
    get tenant_right_path(state_slug: "narnia")
    assert_redirected_to tenant_rights_path
  end

  test "show works for hyphenated state slugs" do
    get tenant_right_path(state_slug: "new-york")
    assert_response :success
    assert_select "h1", /New York Tenant Rights/
  end
end
