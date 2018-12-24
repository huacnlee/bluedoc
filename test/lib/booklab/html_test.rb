# frozen_string_literal: true

require "test_helper"

class BookLab::HTMLTest < ActiveSupport::TestCase
  test "render markdown" do
    raw = "# This is title\nhello **world**"
    out = BookLab::HTML.render(raw, format: :markdown)
    html = %(<h1 id="this-is-title"><a href="#this-is-title" class="heading-anchor">#</a>This is title</h1>\n<p>hello <strong>world</strong></p>)

    assert_equal out, BookLab::HTML.render_without_cache(raw, format: :markdown)
    assert_html_equal html, out

    # cache test
    cache_key = ["booklab/html", "v1", Digest::MD5.hexdigest(raw), { format: :markdown }]
    Rails.cache.write(cache_key, "A cache value")
    assert_equal "A cache value", BookLab::HTML.render(raw, format: :markdown)
    Rails.cache.delete(cache_key)
    assert_html_equal html, BookLab::HTML.render(raw, format: :markdown)
  end

  test "render html with Sanitize" do
    raw = <<~HTML
    <div id="this-is-title" data-name="foo" style="color:red">
      <a href="#this-is-title" target="_blank" rel="nofollow" class="heading-anchor">#</a> This is title
    </div>
    <img src="/foo.png" width="300" height="220" alt="this is img">
    <p data-title="Bar" style="background: red; background-color: red;">hello <strong>world</strong></p>
    HTML
    assert_equal raw, BookLab::HTML.render(raw)
    assert_equal raw, BookLab::HTML.render(raw, format: :html)
  end

  test "render sml" do
    raw = <<~SML
    ["div",
      ["span",{"data-type":"color", "style": "color:green"},"",
        ["a",{"title":"Ruby on Rails","href":"https://rubyonrails.org"},"Ruby on Rails"]
      ]
    ]
    SML
    out = BookLab::HTML.render_without_cache(raw, format: :sml)

    html = <<~HTML
    <div>
      <span data-type="color" style="color:green">
      <a title="Ruby on Rails" href="https://rubyonrails.org">Ruby on Rails</a>
      </span>
    </div>
    HTML

    assert_html_equal html, out
    assert_html_equal out, BookLab::HTML.render_without_cache(raw, format: :sml)
  end

  test "markdown heading" do
    assert_html_equal %(<h1 id="this-is-title"><a href="#this-is-title" class="heading-anchor">#</a>This is title</h1>), BookLab::HTML.render("# This is **title**", format: :markdown)
    assert_html_equal %(<h1 id="this-is-"><a href="#this-is-" class="heading-anchor">#</a>This is 中文</h1>), BookLab::HTML.render("# This is 中文", format: :markdown)
    assert_html_equal %(<h1 id="this-is"><a href="#this-is" class="heading-anchor">#</a>This_? is</h1>), BookLab::HTML.render("# This_? is", format: :markdown)
    assert_html_equal %(<h1 id="a69b2addd"><a href="#a69b2addd" class="heading-anchor">#</a>全中文标题</h1>), BookLab::HTML.render("# 全中文标题", format: :markdown)
  end

  test "markdown mention" do
    raw = <<~MD
    Hello @huacnlee this is a mention. `@title = "AAA"`

    ```rb
    @name = "Foo bar"
    ```

    @nowazhu bla bla.
    MD

    out = BookLab::HTML.render(raw, format: :markdown)

    html = %(
    <p>Hello <a href="/huacnlee" class="user-mention" title="@huacnlee"><i>@</i>huacnlee</a> this is a mention. <code>@title = "AAA"</code></p>
    <div class="highlight">
      <pre class="highlight ruby"><code><span class="vi">@name</span><span class="o">=</span><span class="s2">"Foo bar"</span></code></pre>
    </div>
    <p><a href="/nowazhu" class="user-mention" title="@nowazhu"><i>@</i>nowazhu</a> bla bla.</p>
    )
    assert_html_equal html, out
  end

  test "markdown attachment-file" do
    raw = <<~MD
    [This is a attachment](/uploads/foobar)
    MD

    out = BookLab::HTML.render(raw, format: :markdown)
    assert_html_equal %(<p><a class="attachment-file" href="/uploads/foobar" title="" target="_blank">This is a attachment</a></p>), out

    # empty link should work
    raw = <<~MD
    [This is a attachment]()
    MD
    out = BookLab::HTML.render(raw, format: :markdown)
    assert_html_equal %(<p><a href="">This is a attachment</a></p>), out

  end

  test "markdown image" do
    out = BookLab::HTML.render("![Hello](/uploads/aa.jpg)", format: :markdown)
    assert_equal %(<p><img src="/uploads/aa.jpg" title="" alt="Hello"></p>), out

    out = BookLab::HTML.render("![](/uploads/aa.jpg =300x200)", format: :markdown)
    assert_equal %(<p><img src="/uploads/aa.jpg" width="300" height="200" alt=""></p>), out

    out = BookLab::HTML.render("![](/uploads/aa.jpg | width=300)", format: :markdown)
    assert_equal %(<p><img src="/uploads/aa.jpg" width="300" alt=""></p>), out

    out = BookLab::HTML.render("![](/uploads/aa.jpg | height=300)", format: :markdown)
    assert_equal %(<p><img src="/uploads/aa.jpg" height="300" alt=""></p>), out
  end

  test "markdown html chars" do
    raw = "The > or < will >< keep, and <b>will</b> strong."
    out = BookLab::HTML.render(raw, format: :markdown)
    assert_equal %(<p>The &gt; or &lt; will &gt;&lt; keep, and <b>will</b> strong.</p>), out
  end

  test "markdown render full" do
    raw = read_file("sample.md")
    out = BookLab::HTML.render(raw, format: :markdown)
    expected = read_file("sample.html")

    # puts "\n--------------------------------------\n" + out
    # puts "\n--------------------------------------\n"
    assert_html_equal expected.strip, out
  end

  test "markdown render_public" do
    blob0 = create(:blob)
    blob1 = create(:blob)

    raw = <<~MD
    ![](/uploads/#{blob0.key})

    ## Hello world

    ![](/uploads/#{blob1.key})
    ![](/uploads/not-found-key)

    ![](https://www.google.com.hk/test.png)
    MD

    fake_url0 = "https://foo.bar.com/aaa.jpg"
    fake_url1 = "https://foo.bar.com/bbb.jpg"

    html = <<~HTML
    <p><img src="#{fake_url0}" alt=""></p>
    <h2 id="hello-world">
    <a href="#hello-world" class="heading-anchor">#</a>Hello world</h2>
    <p><img src="#{fake_url1}" alt=""></p>
    <p><img src="/uploads/not-found-key" alt=""></p>

    <p><img src="https://www.google.com.hk/test.png" alt=""></p>
    HTML

    find_stub = Proc.new do |opts|
      return blob0 if opts[:key] == blob0.key
      return blob1 if opts[:key] == blob1.key
      nil
    end

    ActiveStorage::Blob.stub(:find_by, find_stub) do
      blob0.stub(:service_url, fake_url0) do
        blob1.stub(:service_url, fake_url1) do
          out = BookLab::HTML.render(raw, format: :markdown, public: true)
          assert_html_equal html, out
        end
      end
    end
  end
end
