# frozen_string_literal: true

require "test_helper"

class ExportableTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "Doc export_pdf" do
    doc = create(:doc, body: "Hello world")
    assert_nil doc.pdf_url

    assert_enqueued_with job: PDFExportJob do
      doc.export_pdf
    end
    assert_equal "running", doc.export_pdf_status.value

    doc.pdf.attach(io: load_file("blank.png"), filename: "blank.pdf")
    assert_equal "#{Setting.host}/uploads/#{doc.pdf.blob.key}", doc.pdf_url
  end
end
