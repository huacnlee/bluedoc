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
    assert_equal doc.title, html_node.css(".pdf-title")[0].inner_text.strip
    assert_html_equal doc.body_public_html, html_node.css(".markdown-body")[0].inner_html

    assert_equal "done", doc.export_pdf_status.value
    assert_equal true, doc.pdf.attached?
    assert_equal doc.pdf_filename, doc.pdf.blob.filename.to_s

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

  test "perform with Repository without TOC" do
    repo = create(:repository)
    doc0 = create(:doc, repository: repo, body: "Doc 0")
    doc1 = create(:doc, repository: repo, body: "Doc 1")
    doc2 = create(:doc, repository: repo, body: "Doc 2")
    doc3 = create(:doc, repository: repo, body: "Doc 3")
    doc4 = create(:doc, repository: repo, body: "Doc 4")

    doc3.update(body: "Doc 3 new")

    f = WickedPdf::WickedPdfTempfile.new("blank.png")

    rendered_html = ""
    wicked = MiniTest::Mock.new
    wicked.expect(:pdf_from_string, f) do |html, opts|
      rendered_html = html
    end

    WickedPdf.stub(:new, wicked) do
      PDFExportJob.perform_now(repo)
    end
    wicked.verify

    assert_not_equal "", rendered_html

    html_node = Nokogiri::HTML(rendered_html)
    assert_equal repo.name, html_node.css("title")[0].inner_text.strip
    assert_equal repo.name, html_node.css(".pdf-title")[0].inner_text.strip

    assert_equal 5, html_node.css(".markdown-body .doc-section").size
    assert_equal 5, html_node.css(".markdown-body .doc-title").size
    assert_equal 5, html_node.css(".markdown-body .section-body").size
    assert_html_equal doc3.title, html_node.css(".markdown-body .doc-section:first-child .doc-title").inner_text
    assert_html_equal doc3.body_html, html_node.css(".markdown-body .doc-section:first-child .section-body").inner_html

    assert_html_equal doc0.title, html_node.css(".markdown-body .doc-section:last-child .doc-title").inner_text
    assert_html_equal doc0.body_html, html_node.css(".markdown-body .doc-section:last-child .section-body").inner_html

    assert_equal "done", repo.export_pdf_status.value
    assert_equal true, repo.pdf.attached?
    assert_equal repo.pdf_filename, repo.pdf.blob.filename.to_s

    wicked.expect(:pdf_from_string, f) do |args|
      raise "Error"
    end
    repo.export_pdf_status = "running"
    assert_changes -> { ExceptionTrack::Log.count }, 1 do
      WickedPdf.stub(:new, wicked) do
        PDFExportJob.perform_now(repo)
      end
    end
    assert_equal "done", repo.export_pdf_status.value
  end
end
