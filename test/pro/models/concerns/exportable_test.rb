# frozen_string_literal: true

require "test_helper"

class ExportableTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "Doc" do
    doc = create(:doc, body: "Hello world")
    assert_nil doc.export_url(:pdf)
    assert_equal "#{doc.title}.pdf", doc.export_filename(:pdf)
    doc.title = "Hello/world"
    assert_equal "Hello-world.pdf", doc.export_filename(:pdf)

    assert_check_feature do
      doc.export(:pdf)
    end

    allow_feature(:export_pdf) do
      assert_enqueued_with job: PDFExportJob do
        doc.export(:pdf)
      end
      assert_equal "running", doc.export_pdf_status.value
    end

    doc.update_export!(:pdf, load_file("blank.png"))
    assert_equal "#{Setting.host}/uploads/#{doc.pdf.blob.key}", doc.export_url(:pdf)
    assert_equal "Hello-world.pdf", doc.pdf.blob.filename.to_s
  end

  test "Note" do
    note = create(:note, body: "Hello world")
    assert_nil note.export_url(:pdf)
    assert_equal "#{note.title}.pdf", note.export_filename(:pdf)
    note.title = "Hello/world"
    assert_equal "Hello-world.pdf", note.export_filename(:pdf)

    assert_check_feature do
      note.export(:pdf)
    end

    allow_feature(:export_pdf) do
      assert_enqueued_with job: PDFExportJob do
        note.export(:pdf)
      end
      assert_equal "running", note.export_pdf_status.value
    end

    note.update_export!(:pdf, load_file("blank.png"))
    assert_equal "#{Setting.host}/uploads/#{note.pdf.blob.key}", note.export_url(:pdf)
    assert_equal "Hello-world.pdf", note.pdf.blob.filename.to_s
  end

  test "Repository with PDF" do
    repo = create(:repository, name: "测试/Repo")
    assert_nil repo.export_url(:pdf)
    assert_equal "测试-Repo.pdf", repo.export_filename(:pdf)

    assert_check_feature do
      repo.export(:pdf)
    end

    allow_feature(:export_pdf) do
      assert_enqueued_with job: PDFExportJob do
        repo.export(:pdf)
      end
    end
    assert_equal "running", repo.export_pdf_status.value
    assert_equal "running", repo.export_status(:pdf).value

    repo.update_export!(:pdf, load_file("blank.png"))
    assert_equal "#{Setting.host}/uploads/#{repo.pdf.blob.key}", repo.export_url(:pdf)
    assert_equal "测试-Repo.pdf", repo.pdf.blob.filename.to_s
  end

  test "Repository with Archive" do
    repo = create(:repository, name: "测试/Repo")
    assert_nil repo.export_url(:archive)
    assert_equal "测试-Repo.zip", repo.export_filename(:archive)

    assert_check_feature do
      repo.export(:archive)
    end

    allow_feature(:export_archive) do
      assert_enqueued_with job: ArchiveExportJob do
        repo.export(:archive)
      end
    end
    assert_equal "running", repo.export_archive_status.value
    assert_equal "running", repo.export_status(:archive).value

    repo.update_export!(:archive, load_file("blank.png"))
    assert_equal "#{Setting.host}/uploads/#{repo.archive.blob.key}", repo.export_url(:archive)
    assert_equal "测试-Repo.zip", repo.archive.blob.filename.to_s
  end
end
