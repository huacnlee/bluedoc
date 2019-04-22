# frozen_string_literal: true

require "test_helper"

# test Sanitize via ApplicationHelper methods
class BlueDoc::SanitizeTest < ActionView::TestCase
  include ApplicationHelper

  test "markdown" do
    assert_sanitize_same '<a href="/foo">foo</a>'
    assert_sanitize_same '<a href="http://foobar.com/foo">foo</a>'
  end

  test "links" do
    assert_sanitize "<a>link</a>", '<a href="javascript:alert()">link</a>'
    assert_sanitize "foo", "<script>alert("");</script>foo"
    assert_sanitize "foobar", "foo<style>.body{}</style>bar"
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

  test "html chars" do
    raw = "The > or < will >< keep, and <b>will</b> strong."
    out = BlueDoc::HTML.render_without_cache(raw, format: :markdown)
    assert_equal "<p>The &gt; or &lt; will &gt;&lt; keep, and <b>will</b> strong.</p>", out
  end

  test "video" do
    raw = <<~VIDEO
    <video controls="controls" preload="no" width="300" height="200">
      <source src="/uploads/foo" type="video/mov">
    </video>
    VIDEO
    assert_sanitize raw, raw
  end

  test "css properties" do
    raw = %(<p style="foo: 1">Hello</p>)
    assert_sanitize %(<p>Hello</p>), raw

    raw = %(<p style="text-indent: 10px; padding-left: 40px; width: 100px; height: 100px;">Hello</p>)
    assert_sanitize raw, raw
  end

  test "nid attribute" do
    raw = %(<p nid="Snk2l3">Hello</p><div nid="lkn2SK"><ul nid="lkajsd"></ul></div>)
    assert_sanitize raw, raw
  end

  private

    def assert_sanitize(expected, html)
      assert_equal expected, BlueDoc::HTML.render_without_cache(html, format: :html)
      assert_equal expected, sanitize_html(html)
    end

    def assert_sanitize_same(html)
      assert_sanitize html, html
    end
end
