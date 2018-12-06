# frozen_string_literal: true

require "test_helper"

class MarkdownableTest < ActiveSupport::TestCase
  include ActionView::Helpers::OutputSafetyHelper
  include ApplicationHelper

  test "Doc" do
    body = read_file("sample.md")
    body_html = markdown(body)

    doc = create(:doc, body: body)
    assert_equal body, doc.body_plain
    assert_html_equal body_html, doc.body_html
  end

  test "Comment" do
    body = read_file("sample.md")
    body_html = markdown(body)

    comment = create(:comment, body: body)
    assert_equal body, comment.body_plain
    assert_html_equal body_html, comment.body_html
  end
end
