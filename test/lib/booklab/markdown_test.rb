# frozen_string_literal: true

require "test_helper"

class BookLab::MarkdownTest < ActiveSupport::TestCase
  test "render" do
    raw = "# This is title\nhello **world**"
    out = BookLab::Markdown.render(raw)
    assert_html_equal %(<h1 id="this-is-title"><a href="#this-is-title" class="heading-anchor">#</a>This is title</h1>\n<p>hello <strong>world</strong></p>), out
  end

  test "heading" do
    assert_html_equal %(<h1 id="this-is-title"><a href="#this-is-title" class="heading-anchor">#</a>This is title</h1>), BookLab::Markdown.render("# This is **title**")
    assert_html_equal %(<h1 id="this-is-"><a href="#this-is-" class="heading-anchor">#</a>This is 中文</h1>), BookLab::Markdown.render("# This is 中文")
    assert_html_equal %(<h1 id="this-is"><a href="#this-is" class="heading-anchor">#</a>This_? is</h1>), BookLab::Markdown.render("# This_? is")
    assert_html_equal %(<h1 id="a69b2addd"><a href="#a69b2addd" class="heading-anchor">#</a>全中文标题</h1>), BookLab::Markdown.render("# 全中文标题")
  end

  test "mention" do
    raw = <<~MD
    Hello @huacnlee this is a mention. `@title = "AAA"`

    ```rb
    @name = "Foo bar"
    ```

    @nowazhu bla bla.
    MD

    out = BookLab::Markdown.render(raw)

    html = %(
    <p>Hello <a href="/huacnlee" class="user-mention" title="@huacnlee"><i>@</i>huacnlee</a> this is a mention. <code>@title = "AAA"</code></p>
    <div class="highlight">
      <pre class="highlight ruby"><code><span class="vi">@name</span><span class="o">=</span><span class="s2">"Foo bar"</span></code></pre>
    </div>
    <p><a href="/nowazhu" class="user-mention" title="@nowazhu"><i>@</i>nowazhu</a> bla bla.</p>
    )
    assert_html_equal html, out
  end

  test "attachment-file" do
    raw = <<~MD
    [This is a attachment](/uploads/foobar)
    MD

    out = BookLab::Markdown.render(raw)
    assert_html_equal %(<p><a class="attachment-file" href="/uploads/foobar" title="" target="_blank">This is a attachment</a></p>), out
  end

  test "html chars" do
    raw = "The > or < will >< keep, and <b>will</b> strong."
    out = BookLab::Markdown.render(raw)
    assert_equal %(<p>The &gt; or &lt; will &gt;&lt; keep, and <b>will</b> strong.</p>), out
  end

  test "render full" do
    raw = read_file("sample.md")
    out = BookLab::Markdown.render(raw)
    expected = read_file("sample.html")

    # puts "\n--------------------------------------\n" + out
    # puts "\n--------------------------------------\n"
    assert_html_equal expected.strip, out
  end
end
