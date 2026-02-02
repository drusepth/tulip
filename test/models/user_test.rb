require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "name returns display_name when set" do
    user = User.new(email: "test@example.com", display_name: "Jane Doe")
    assert_equal "Jane Doe", user.name
  end

  test "name falls back to email username when display_name is blank" do
    user = User.new(email: "test@example.com", display_name: nil)
    assert_equal "test", user.name

    user.display_name = ""
    assert_equal "test", user.name
  end
end
