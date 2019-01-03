# frozen_string_literal: true

require "test_helper"

class BookLab::HTMLTest < ActiveSupport::TestCase
  test "render markdown" do
    raw = <<~RAW
    # This is **title**

    hello **world**
    RAW
    out = BookLab::HTML.render(raw, format: :markdown)
    html = <<~HTML
    <h1 id="this-is-title">
      <a href="#this-is-title" class="heading-anchor">#</a>This is <strong>title</strong>
    </h1>
    <p>hello <strong>world</strong></p>
    HTML

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
    assert_html_equal %(<h1 id="this-is-title"><a href="#this-is-title" class="heading-anchor">#</a>This is <strong>title</strong></h1>), BookLab::HTML.render("# This is **title**", format: :markdown)
    assert_html_equal %(<h1 id="this-is-title"><a href="#this-is-title" class="heading-anchor">#</a>This is 中文 title</h1>), BookLab::HTML.render("# This is 中文 title", format: :markdown)
    assert_html_equal %(<h1 id="this-is"><a href="#this-is" class="heading-anchor">#</a>This_? is</h1>), BookLab::HTML.render("# This_? is", format: :markdown)
    assert_html_equal %(<h1 id="a69b2addd"><a href="#a69b2addd" class="heading-anchor">#</a>全中文标题</h1>), BookLab::HTML.render("# 全中文标题", format: :markdown)
    assert_html_equal %(<h1 id="583a03ad8"><a href="#583a03ad8" class="heading-anchor">#</a>确保 id 生成是固定的编号</h1>), BookLab::HTML.render("# 确保 id 生成是固定的编号", format: :markdown)
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
    [This is a attachment](/uploads/foobar "size:12872363")
    MD
    html = <<~HTML
    <p>
      <a class="attachment-file" title="This is a attachment" target="_blank" href="/uploads/foobar">
        <span class="icon-box"><i class="fas fa-file"></i></span>
        <span class="filename">This is a attachment</span>
        <span class="filesize">12.3 MB</span>
      </a>
    </p>
    HTML
    out = BookLab::HTML.render(raw, format: :markdown)
    assert_html_equal html, out

    raw = <<~MD
    [download: This is a attachment <script>](/uploads/foobar)
    MD
    html = <<~HTML
    <p>
      <a class="attachment-file" title="This is a attachment" target="_blank" href="/uploads/foobar">
        <span class="icon-box"><i class="fas fa-file"></i></span>
        <span class="filename">This is a attachment</span>
        <span class="filesize"></span>
      </a>
    </p>
    HTML
    out = BookLab::HTML.render(raw, format: :markdown)
    assert_html_equal html, out


    # empty link should work
    raw = <<~MD
    [This is a attachment]()
    MD
    out = BookLab::HTML.render(raw, format: :markdown)
    assert_html_equal %(<p><a href="">This is a attachment</a></p>), out
  end

  test "markdown image" do
    out = BookLab::HTML.render("![Hello](/uploads/aa.jpg)", format: :markdown)
    assert_equal %(<p><img src="/uploads/aa.jpg" alt="Hello"></p>), out

    html = %(<img src="/uploads/aa.jpg" alt="Hello" width="300" height="200" style="width:300px; height:200px;">)
    assert_equal html, BookLab::HTML.render(html, format: :markdown)
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

  test "markdown with bad link" do
    assert_equal %(<p><a href=""></a></p>), BookLab::HTML.render("[]()", format: :markdown)
  end

  test "markdown render_public" do
    blob0 = create(:blob)
    blob1 = create(:blob)

    raw = <<~MD
    ![](/uploads/#{blob0.key})

    [Download File](/uploads/foobar)

    ## Hello world

    ![](/uploads/#{blob1.key})

    ![](/uploads/not-found-key)

    ![](https://www.google.com.hk/test.png)

    [download: The File](https://www.google.com.hk/test.zip)
    MD

    fake_url0 = "https://foo.bar.com/aaa.jpg"
    fake_url1 = "https://foo.bar.com/bbb.jpg"

    html = <<~HTML
    <p><img src="#{fake_url0}" alt=""></p>
    <p>
      <a class="attachment-file" title="Download File" target="_blank" href="#{Setting.host}/uploads/foobar">
        <span class="icon-box"><i class="fas fa-file"></i></span>
        <span class="filename">Download File</span>
        <span class="filesize"></span>
      </a>
    </p>
    <h2 id="hello-world">
    <a href="#hello-world" class="heading-anchor">#</a>Hello world</h2>
    <p><img src="#{fake_url1}" alt=""></p>
    <p><img src="/uploads/not-found-key" alt=""></p>

    <p><img src="https://www.google.com.hk/test.png" alt=""></p>
    <p>
      <a class="attachment-file" title="The File" target="_blank" href="https://www.google.com.hk/test.zip">
        <span class="icon-box"><i class="fas fa-file"></i></span>
        <span class="filename">The File</span>
        <span class="filesize"></span>
      </a>
    </p>
    HTML

    find_stub = lambda do |opts|
      return blob0 if opts[:key] == blob0.key
      return blob1 if opts[:key] == blob1.key
      return nil
    end

    out = nil

    ActiveStorage::Blob.stub(:find_by, find_stub) do
      blob0.stub(:service_url, fake_url0) do
        blob1.stub(:service_url, fake_url1) do
          out = BookLab::HTML.render(raw, format: :markdown, public: true)
        end
      end
    end

    assert_html_equal html, out
  end
end
