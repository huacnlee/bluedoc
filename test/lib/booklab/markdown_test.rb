# frozen_string_literal: true

require "test_helper"

class BookLab::MarkdownTest < ActiveSupport::TestCase
  test "render" do
    raw = "# This is title\nhello **world**"
    out = BookLab::Markdown.render(raw)
    assert_equal %(<h1 id="this-is-title"><a href="#this-is-title" class="heading-anchor">#</a>This is title</h1>\n<p>hello <strong>world</strong></p>), out
  end

  test "heading" do
    assert_equal %(<h1 id="this-is-title"><a href="#this-is-title" class="heading-anchor">#</a>This is title</h1>), BookLab::Markdown.render("# This is **title**")
    assert_equal %(<h1 id="this-is-"><a href="#this-is-" class="heading-anchor">#</a>This is 中文</h1>), BookLab::Markdown.render("# This is 中文")
    assert_equal %(<h1 id="this-is"><a href="#this-is" class="heading-anchor">#</a>This_? is</h1>), BookLab::Markdown.render("# This_? is")
    assert_equal %(<h1 id="a69b2addd"><a href="#a69b2addd" class="heading-anchor">#</a>全中文标题</h1>), BookLab::Markdown.render("# 全中文标题")
  end

  test "render full" do
    raw = read_file("sample.md")
    out = BookLab::Markdown.render(raw)
    expected = read_file("sample.html")

    if out != expected.strip
      puts "\n--------------------------------------\n" + out
      puts "\n--------------------------------------\n"
      assert_equal expected.strip, out
    end
  end
end
