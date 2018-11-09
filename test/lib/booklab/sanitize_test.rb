# frozen_string_literal: true

require "test_helper"

# test Sanitize via ApplicationHelper methods
class BookLab::SanitizeTest < ActionView::TestCase
  include ApplicationHelper

  test "markdown" do
    assert_sanitize_same '<a href="/foo">foo</a>'
    assert_sanitize_same '<a href="http://foobar.com/foo">foo</a>'
  end

  test "links" do
    assert_sanitize "<a>link</a>", '<a href="javascript:alert()">link</a>'
    assert_sanitize "alert();", "<script>alert("");</script>"
    assert_sanitize ".body{}", "<style>.body{}</style>"
    assert_sanitize "", '<iframe src="https://foobar.com"></iframe>'

    html = '<a href="http://www.google.com" data-floor="100" target="_blank" rel="nofollow" class="btn btn-lg">111</a>'
    assert_sanitize_same html
  end

  test "images" do
    html = '<img src="javascript:alert" class="emoji" width="100" height="100">'
    assert_sanitize '<img class="emoji" width="100" height="100">', html

    html = '<img src="javascript:alert('')">'
    assert_sanitize "<img>", html

    html = '<img src="/img/a.jpg" class="emoji" width="100" height="100">'
    assert_sanitize_same html

    html = '<img src="http://foo.com/img/a.jpg" class="emoji" width="100" height="100">'
    assert_sanitize_same html

    html = '<img src="https://foo.com/img/a.jpg" class="emoji" width="100" height="100">'
    assert_sanitize_same html

    html = '<img src="//foo.com/img/a.jpg" class="emoji" width="100" height="100">'
    assert_sanitize_same html
  end

  test "iframe with Youtube" do
    html = '<span class="embed-responsive embed-responsive-16by9">
        <iframe width="560" height="315" src="https://www.youtube.com/embed/gFQpxAKx_ds" class="embed" frameborder="0" allowfullscreen=""></iframe>
        </span>'
    assert_sanitize_same html

    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="https://player.vimeo.com/video/159449591" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_sanitize_same html

    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="http://www.youtube.com/embed/gFQpxAKx_ds" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_sanitize_same html

    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="//www.youtube.com/embed/gFQpxAKx_ds" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_sanitize_same html

    html = '<iframe width="560" height="315" src="//www.youtube.com/aaa" class="embed" frameborder="0" allowfullscreen=""></iframe>'
    assert_sanitize "", html
  end

  test "iframe with Youku" do
    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="https://player.youku.com/embed/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_sanitize_same html

    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="http://player.youku.com/embed/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_sanitize_same html

    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="//player.youku.com/embed/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_sanitize_same html

    html = '<iframe width="560" height="315" src="//player.youku.com/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>'
    assert_sanitize "", html

    html = '<iframe width="560" height="315" src="//www.youku.com/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>'
    assert_sanitize "", html
  end

  private

    def assert_sanitize(expected, html)
      assert_equal expected, sanitize_html(html)
    end

    def assert_sanitize_same(html)
      assert_sanitize html, html
    end
end
