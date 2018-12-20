# frozen_string_literal: true

require "test_helper"

class SmlableTest < ActiveSupport::TestCase
  test "Doc" do
    # Markdown
    body = read_file("sample.md")
    body_html = BookLab::HTML.render(body, format: :markdown)

    doc = create(:doc, body: body, format: :markdown)
    assert_equal body, doc.body_plain
    assert_html_equal body_html, doc.body_html

    stub_method = Proc.new do |body, opts|
      opts[:public] ? "Render public" : body
    end

    BookLab::HTML.stub(:render, stub_method) do
      assert_equal "Render public", doc.body_public_html
    end

    # SML
    raw = <<~SML
    ["div",
      ["span",{"data-type":"color", "style": "color:green"},"",
        ["a",{"title":"Ruby on Rails","href":"https://rubyonrails.org"},"Ruby on Rails"]
      ]
    ]
    SML
    doc = create(:doc, body_sml: raw, format: :sml)
    assert_equal raw, doc.body_sml_plain
    assert_equal BookLab::HTML.render(raw, format: :sml), doc.body_html

    BookLab::HTML.stub(:render, stub_method) do
      assert_equal "Render public", doc.body_public_html
    end
  end

  test "Version" do
    body = read_file("sample.md")
    body_html = BookLab::HTML.render(body, format: :markdown)

    doc = create(:doc, body: body, format: :markdown)
    version = doc.versions.last

    assert_equal body, version.body_plain
    assert_equal body_html, body_html

    stub_method = Proc.new do |body, opts|
      opts[:public] ? "Render public" : body
    end

    BookLab::HTML.stub(:render, stub_method) do
      assert_equal "Render public", version.body_public_html
    end
  end
end
