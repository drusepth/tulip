require "test_helper"

class AvatarHelperTest < ActionView::TestCase
  include AvatarHelper

  def setup
    @user = users(:one)
  end

  test "avatar_url generates valid DiceBear URL" do
    url = avatar_url(@user)

    assert_includes url, "https://api.dicebear.com/7.x/lorelei/svg"
    assert_includes url, "seed="
    assert_includes url, "size=80"
    assert_includes url, "backgroundColor="
  end

  test "avatar_url uses MD5 hash of email as seed" do
    expected_seed = Digest::MD5.hexdigest(@user.email.strip.downcase)
    url = avatar_url(@user)

    assert_includes url, "seed=#{expected_seed}"
  end

  test "avatar_url respects custom size" do
    url = avatar_url(@user, size: 120)

    assert_includes url, "size=120"
  end

  test "avatar_url uses default seed for nil user" do
    url = avatar_url(nil)

    assert_includes url, "seed=default"
  end

  test "avatar_url uses default seed for user with blank email" do
    @user.email = ""
    url = avatar_url(@user)

    assert_includes url, "seed=default"
  end

  test "avatar_url picks background color based on seed" do
    url = avatar_url(@user)
    backgrounds = %w[b8c9b8 d4a5a5 c9b8a8 c8bfd4 fdf8f3]

    assert backgrounds.any? { |bg| url.include?("backgroundColor=#{bg}") }
  end

  test "avatar_tag generates image tag with correct attributes" do
    tag = avatar_tag(@user, size: 32)

    assert_includes tag, "<img"
    assert_includes tag, "rounded-full"
    assert_includes tag, 'alt="Avatar"'
    assert_includes tag, "api.dicebear.com"
  end

  test "avatar_tag merges custom classes" do
    tag = avatar_tag(@user, html_options: { class: "custom-class" })

    assert_includes tag, "rounded-full"
    assert_includes tag, "custom-class"
  end

  test "avatar_tag allows custom alt text" do
    tag = avatar_tag(@user, html_options: { alt: "User avatar" })

    assert_includes tag, 'alt="User avatar"'
  end
end
