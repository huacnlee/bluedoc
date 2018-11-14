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
    html = icon_tag("times", label: "Close", class: "search")
    assert_equal %(<i class="octicon fas fa-times search"></i> <span>Close</span>), html
  end

  test "timeago" do
    t = Time.now

    html = timeago(t)
    assert_equal %(<span class="timeago" title="#{t.iso8601}">#{t.iso8601}</span>), html

    t = 1.month.ago
    html = timeago(t)
    assert_equal %(<span class="time" title="#{t.iso8601}">#{l t, format: :short}</span>), html
  end

  private

    def assert_sanitize_markdown(excepted, raw)
      assert_equal excepted, markdown(raw)
    end
end
