# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "markdown" do
    raw = "Hello **world**, this is a __test__."
    html = "<p>Hello <strong>world</strong>, this is a <strong>test</strong>.</p>"
    assert_equal html, markdown(raw)

    cache_key = ["markdown", "v1", Digest::MD5.hexdigest(raw)]
    Rails.cache.write(cache_key, "A cache value")
    assert_equal "A cache value", markdown(raw)

    Rails.cache.delete(cache_key)
    assert_equal html, markdown(raw)
  end

  test "sanitize markdown" do
    assert_sanitize_markdown "<p>alert() foo</p>", "<script>alert()</script> foo"
    assert_sanitize_markdown "<p>.body {} foo</p>", "<style>.body {}</style> foo"
  end

  test "icon_tag" do
    html = icon_tag("x", label: "Close")
    assert_equal "<svg class=\"octicon octicon-x\" viewBox=\"0 0 12 16\" version=\"1.1\" width=\"12\" height=\"16\" aria-hidden=\"true\"><path fill-rule=\"evenodd\" d=\"M7.48 8l3.75 3.75-1.48 1.48L6 9.48l-3.75 3.75-1.48-1.48L4.52 8 .77 4.25l1.48-1.48L6 6.52l3.75-3.75 1.48 1.48L7.48 8z\"/></svg> <span>Close</span>", html
  end

  test "timeago" do
    t = Time.now

    html = timeago(t)
    assert_equal %(<span class="timeago" title="#{t.iso8601}">#{t.iso8601}</span>), html
  end

  private

    def assert_sanitize_markdown(excepted, raw)
      assert_equal excepted, markdown(raw)
    end
end
