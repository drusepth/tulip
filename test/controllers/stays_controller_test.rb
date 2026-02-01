require "test_helper"

class StaysControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user_one = users(:one)
    @user_two = users(:two)
    @stay_one = stays(:one)
    @stay_two = stays(:two)
  end

  # Owner access tests
  test "owner can view their stay" do
    sign_in @user_one
    get stay_path(@stay_one)
    assert_response :success
  end

  test "owner can edit their stay" do
    sign_in @user_one
    get edit_stay_path(@stay_one)
    assert_response :success
  end

  test "owner can update their stay" do
    sign_in @user_one
    patch stay_path(@stay_one), params: { stay: { title: "Updated Title" } }
    assert_redirected_to stay_path(@stay_one)
    @stay_one.reload
    assert_equal "Updated Title", @stay_one.title
  end

  test "owner can delete their stay" do
    sign_in @user_one
    assert_difference("Stay.count", -1) do
      delete stay_path(@stay_one)
    end
    assert_redirected_to stays_path
  end

  # Collaborator access tests (user_two has accepted collaboration on stay_one)
  test "collaborator can view shared stay" do
    sign_in @user_two
    get stay_path(@stay_one)
    assert_response :success
  end

  test "collaborator can edit shared stay" do
    sign_in @user_two
    get edit_stay_path(@stay_one)
    assert_response :success
  end

  test "collaborator can update shared stay" do
    sign_in @user_two
    patch stay_path(@stay_one), params: { stay: { notes: "Collaborator note" } }
    assert_redirected_to stay_path(@stay_one)
    @stay_one.reload
    assert_equal "Collaborator note", @stay_one.notes
  end

  test "collaborator cannot delete shared stay" do
    sign_in @user_two
    assert_no_difference("Stay.count") do
      delete stay_path(@stay_one)
    end
    assert_redirected_to stay_path(@stay_one)
    assert_match /only the owner/i, flash[:alert]
  end

  # Non-collaborator access tests
  test "non-collaborator cannot view stay they don't have access to" do
    sign_in @user_two
    # user_two does NOT have access to stay_two
    get stay_path(@stay_two)
    assert_redirected_to root_path
  end

  test "non-collaborator cannot edit stay they don't have access to" do
    sign_in @user_two
    get edit_stay_path(@stay_two)
    assert_redirected_to root_path
  end

  # Index shows all accessible stays
  test "index shows owned and collaborated stays" do
    sign_in @user_two
    get stays_path
    assert_response :success
    # user_two can see stay_one (collaborator) but should see it in the list
    assert_select "a[href='#{stay_path(@stay_one)}']"
  end

  # Map data includes shared stays
  test "map_data includes collaborated stays" do
    sign_in @user_two
    get api_stays_path, as: :json
    assert_response :success

    stays = JSON.parse(response.body)
    stay_ids = stays.map { |s| s["id"] }
    assert_includes stay_ids, @stay_one.id
  end
end
