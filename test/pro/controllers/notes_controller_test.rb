# frozen_string_literal: true

require "test_helper"

class ProNotesControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user = create(:user)
    @other_user = create(:user)
  end

  test "GET /:user/notes/:slug with readers" do
    note = create(:note)

    user = create(:user)
    users = create_list(:user, 8)

    allow_feature(:reader_list) do
      users.map { |u| u.read_note(note) }
    end

    sign_in user

    get note.to_path
    assert_equal 200, response.status
    assert_select ".note-readers", 0

    allow_feature(:reader_list) do
      get note.to_path
      assert_equal 200, response.status
      assert_select ".note-readers" do
        assert_select "a.readers-link .avatar", 5
      end
      assert_equal true, user.read_note?(note)
    end
  end

  test "GET /:user/notes/:slug/readers" do
    note = create(:note)
    users = create_list(:user, 8)
    allow_feature(:reader_list) do
      users.map { |u| u.read_note(note) }
    end

    assert_check_feature do
      get note.to_path("/readers"), xhr: true
    end

    allow_feature(:reader_list) do
      get note.to_path("/readers"), xhr: true
      assert_equal 200, response.status

      assert_match %(document.querySelector(".note-readers").outerHTML = ), response.body
    end
  end

  test "GET /:user/notes/:slug with PDF export" do
    note = create(:note)
    get note.to_path
    assert_equal 200, response.status

    assert_select ".doc-export-pdf-box", 0

    sign_in @user
    note = create(:note, user: @user)
    get note.to_path
    assert_select ".doc-export-pdf-box", 0

    allow_feature(:export_pdf) do
      get note.to_path
      assert_select ".doc-export-pdf-box details" do
        assert_select ".description", text: "Click button to genrate PDF file for this document."
        assert_select ".btn-generate-pdf" do
          assert_select "[href=?]", note.to_path("/pdf?force=1")
          assert_select "[data-method=?]", "post"
          assert_select "[data-remote=?]", "true"
        end
      end

      # pdf in running
      note.set_export_status(:pdf, "running")
      get note.to_path
      assert_equal 200, response.status
      assert_select ".doc-export-pdf-box details" do
        assert_select ".pdf-export-running"
        assert_select ".btn-generate-pdf", 0
        assert_select ".pdf-export-retry-message" do
          assert_select "a", text: "retry" do
            assert_select "[href=?]", note.to_path("/pdf?force=1")
            assert_select "[data-method=?]", "post"
            assert_select "[data-remote=?]", "true"
          end
        end
      end

      # pdf has done
      note.set_export_status(:pdf, "done")
      note.pdf.attach(io: load_file("blank.png"), filename: "foobar.pdf")
      get note.to_path
      assert_equal 200, response.status
      assert_select ".doc-export-pdf-box details" do
        assert_select ".description", text: "PDF of this document page has been generated."
        assert_select ".btn-download-pdf" do
          assert_select "[href=?]", note.export_url(:pdf)
        end
        assert_select ".btn-regenerate-pdf" do
          assert_select "[href=?]", note.to_path("/pdf?force=1")
          assert_select "[data-method=?]", "post"
          assert_select "[data-remote=?]", "true"
        end
      end
    end
  end

  test "POST /:user/notes/:slug/pdf" do
    def assert_has_pdf_js(response)
      assert_match %(var openStatus = $(".doc-export-pdf-box details[open]");), response.body
      assert_match %($(".doc-export-pdf-box").replaceWith(html);), response.body
      assert_match %($(".doc-export-pdf-box details").attr("open", "");), response.body
    end

    note = create(:note)

    post note.to_path("/pdf"), xhr: true
    assert_equal 401, response.status

    sign_in @user
    assert_check_feature do
      post note.to_path("/pdf"), xhr: true
    end

    allow_feature(:export_pdf) do
      post note.to_path("/pdf"), xhr: true
      assert_equal 403, response.status

      note = create(:note, user: @user)
      assert_no_enqueued_jobs only: PDFExportJob do
        post note.to_path("/pdf"), xhr: true
      end
      assert_equal 200, response.status
      assert_has_pdf_js response
      assert_match %(btn-generate-pdf), response.body

      # generate
      assert_enqueued_with job: PDFExportJob do
        post note.to_path("/pdf?force=1"), xhr: true
      end
      assert_equal 200, response.status
      assert_equal "running", note.export_pdf_status.value
      assert_has_pdf_js response
      assert_match %(pdf-export-running), response.body
      assert_match %(pdf-export-retry-message), response.body

      # check status
      post note.to_path("/pdf?check=1"), xhr: true
      assert_equal 200, response.status
      assert_equal "", response.body.strip

      note.set_export_status(:pdf, "done")
      post note.to_path("/pdf?check=1"), xhr: true
      assert_equal 200, response.status
      assert_has_pdf_js response
      assert_match %(btn-generate-pdf), response.body

      note.pdf.attach(io: load_file("blank.png"), filename: "blank.pdf")
      post note.to_path("/pdf?check=1"), xhr: true
      assert_equal 200, response.status
      assert_has_pdf_js response
      assert_match %(btn-regenerate-pdf), response.body
      assert_match %(btn-download-pdf), response.body

      post note.to_path("/pdf"), xhr: true
      assert_equal 200, response.status
      assert_has_pdf_js response
      assert_match %(btn-regenerate-pdf), response.body
      assert_match %(btn-download-pdf), response.body
    end
  end
end
