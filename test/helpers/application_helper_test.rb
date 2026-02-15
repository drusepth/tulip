require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper
  include Rails.application.routes.url_helpers

  test "render_comment_body returns empty string for blank body" do
    assert_equal "", render_comment_body(nil)
    assert_equal "", render_comment_body("")
  end

  test "render_comment_body renders plain text as-is" do
    assert_equal "Hello world", render_comment_body("Hello world")
  end

  test "render_comment_body escapes HTML in plain text" do
    result = render_comment_body("<script>alert('xss')</script>")
    assert_not_includes result, "<script>"
    assert_includes result, "&lt;script&gt;"
  end

  test "render_comment_body renders place mentions as links" do
    place = places(:blue_bottle)
    body = "Check out @[Blue Bottle Coffee](place:#{place.id}) for great coffee"
    result = render_comment_body(body)

    assert_includes result, "<a href=\"#{place_path(place.id)}\""
    assert_includes result, "class=\"place-mention\""
    assert_includes result, "@Blue Bottle Coffee</a>"
    assert_includes result, "for great coffee"
  end

  test "render_comment_body renders multiple mentions" do
    body = "Visit @[Place One](place:1) and @[Place Two](place:2)!"
    result = render_comment_body(body)

    assert_includes result, "@Place One</a>"
    assert_includes result, "@Place Two</a>"
  end

  test "render_comment_body escapes HTML inside mention names" do
    body = "@[<b>Bad</b>](place:1) test"
    result = render_comment_body(body)

    assert_not_includes result, "<b>"
    assert_includes result, "&lt;b&gt;"
  end
end
