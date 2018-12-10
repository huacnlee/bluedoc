# frozen_string_literal: true

require "test_helper"

class PDFExportJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "perform with Doc" do
    doc = create(:doc, body: read_file("sample.md"))

    f = WickedPdf::WickedPdfTempfile.new("blank.png")

    rendered_html = ""
    wicked = MiniTest::Mock.new
    wicked.expect(:pdf_from_string, f) do |html, opts|
      rendered_html = html
    end

    WickedPdf.stub(:new, wicked) do
      PDFExportJob.perform_now(doc)
    end
    wicked.verify

    assert_not_equal "", rendered_html

    html_node = Nokogiri::HTML(rendered_html)
    assert_equal doc.title, html_node.css("title")[0].inner_text.strip
    assert_equal doc.title, html_node.css("h1.doc-title")[0].inner_text.strip
    assert_html_equal doc.body_public_html, html_node.css(".markdown-body")[0].inner_html

    assert_equal "done", doc.export_pdf_status.value
    assert_equal true, doc.pdf.attached?

    wicked.expect(:pdf_from_string, f) do |args|
      raise "Error"
    end
    doc.export_pdf_status = "running"
    assert_changes -> { ExceptionTrack::Log.count }, 1 do
      WickedPdf.stub(:new, wicked) do
        PDFExportJob.perform_now(doc)
      end
    end
    assert_equal "done", doc.export_pdf_status.value
  end
end
