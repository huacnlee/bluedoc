# frozen_string_literal: true

require "test_helper"

class ExportableTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "Doc" do
    doc = create(:doc, body: "Hello world")
    assert_nil doc.pdf_url
    assert_equal "#{doc.title}.pdf", doc.pdf_filename

    assert_enqueued_with job: PDFExportJob do
      doc.export_pdf
    end
    assert_equal "running", doc.export_pdf_status.value

    doc.pdf.attach(io: load_file("blank.png"), filename: "blank.pdf")
    assert_equal "#{Setting.host}/uploads/#{doc.pdf.blob.key}", doc.pdf_url
  end

  test "Repository" do
    repo = create(:repository)
    assert_nil repo.pdf_url
    assert_equal "#{repo.name}.pdf", repo.pdf_filename

    assert_enqueued_with job: PDFExportJob do
      repo.export_pdf
    end
    assert_equal "running", repo.export_pdf_status.value

    repo.pdf.attach(io: load_file("blank.png"), filename: "blank.pdf")
    assert_equal "#{Setting.host}/uploads/#{repo.pdf.blob.key}", repo.pdf_url
  end
end
