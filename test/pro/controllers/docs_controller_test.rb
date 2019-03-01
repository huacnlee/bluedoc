# frozen_string_literal: true

require "test_helper"

class ProDocsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @group = create(:group)
    @repo = create(:repository, user: @group, slug: "rails")
  end

  test "GET /:user/:repo/:slug with readers" do
    doc = create(:doc)

    user = create(:user)
    users = create_list(:user, 8)

    allow_feature(:reader_list) do
      users.map { |u| u.read_doc(doc) }
    end

    sign_in user

    get doc.to_path
    assert_equal 200, response.status
    assert_select ".doc-readers", 0

    allow_feature(:reader_list) do
      get doc.to_path
      assert_equal 200, response.status
      assert_select ".doc-readers" do
        assert_select "a.readers-link .avatar", 5
      end
    end
  end

  test "GET /:user/:repo/:slug/readers" do
    doc = create(:doc)
    users = create_list(:user, 8)
    allow_feature(:reader_list) do
      users.map { |u| u.read_doc(doc) }
    end

    assert_check_feature do
      get doc.to_path("/readers"), xhr: true
    end

    allow_feature(:reader_list) do
      get doc.to_path("/readers"), xhr: true
      assert_equal 200, response.status

      assert_match %(document.querySelector(".doc-readers").outerHTML = ), response.body
    end
  end

  test "GET /:user/:repo/:slug with PDF" do
    doc = create(:doc, repository: @repo)
    get doc.to_path
    assert_equal 200, response.status
    assert_select ".doc-export-pdf-box", 0

    allow_feature(:export_pdf) do
      get doc.to_path
      assert_equal 200, response.status
      assert_select ".doc-export-pdf-box", 0

      sign_in_role :editor, group: @group
      get doc.to_path
      assert_equal 200, response.status
      assert_select ".doc-export-pdf-box details" do
        assert_select ".description", text: "Click button to genrate PDF file for this document."
        assert_select ".btn-generate-pdf" do
          assert_select "[href=?]", doc.to_path("/pdf?force=1")
          assert_select "[data-method=?]", "post"
          assert_select "[data-remote=?]", "true"
        end
      end

      # pdf in running
      doc.set_export_status(:pdf, "running")
      get doc.to_path
      assert_equal 200, response.status
      assert_select ".doc-export-pdf-box details" do
        assert_select ".pdf-export-running"
        assert_select ".btn-generate-pdf", 0
        assert_select ".pdf-export-retry-message" do
          assert_select "a", text: "retry" do
            assert_select "[href=?]", doc.to_path("/pdf?force=1")
            assert_select "[data-method=?]", "post"
            assert_select "[data-remote=?]", "true"
          end
        end
      end

      # pdf has done
      doc.set_export_status(:pdf, "done")
      doc.pdf.attach(io: load_file("blank.png"), filename: "foobar.pdf")
      get doc.to_path
      assert_equal 200, response.status
      assert_select ".doc-export-pdf-box details" do
        assert_select ".description", text: "PDF of this document page has generated."
        assert_select ".btn-download-pdf" do
          assert_select "[href=?]", doc.export_url(:pdf)
        end
        assert_select ".btn-regenerate-pdf" do
          assert_select "[href=?]", doc.to_path("/pdf?force=1")
          assert_select "[data-method=?]", "post"
          assert_select "[data-remote=?]", "true"
        end
      end
    end
  end

  test "POST /:user/:repo/:slug/pdf" do
    group = create(:group)
    repo = create(:repository, user: group)
    doc = create(:doc, repository: repo)

    def assert_has_pdf_js(response)
      assert_match %(var openStatus = $(".doc-export-pdf-box details[open]");), response.body
      assert_match %($(".doc-export-pdf-box").replaceWith(html);), response.body
      assert_match %($(".doc-export-pdf-box details").attr("open", "");), response.body
    end

    post doc.to_path("/pdf"), xhr: true
    assert_equal 401, response.status

    sign_in @user
    assert_check_feature do
      post doc.to_path("/pdf"), xhr: true
    end

    allow_feature(:export_pdf) do
      post doc.to_path("/pdf"), xhr: true
      assert_equal 403, response.status

      sign_in_role :reader, group: group
      post doc.to_path("/pdf"), xhr: true
      assert_equal 403, response.status

      sign_in_role :editor, group: group
      assert_no_enqueued_jobs only: PDFExportJob do
        post doc.to_path("/pdf"), xhr: true
      end

      assert_equal 200, response.status
      assert_has_pdf_js response
      assert_match %(btn-generate-pdf), response.body

      # generate
      assert_enqueued_with job: PDFExportJob do
        post doc.to_path("/pdf?force=1"), xhr: true
      end
      assert_equal 200, response.status
      assert_equal "running", doc.export_pdf_status.value
      assert_has_pdf_js response
      assert_match %(pdf-export-running), response.body
      assert_match %(pdf-export-retry-message), response.body

      # check status
      post doc.to_path("/pdf?check=1"), xhr: true
      assert_equal 200, response.status
      assert_equal "", response.body.strip

      doc.set_export_status(:pdf, "done")
      post doc.to_path("/pdf?check=1"), xhr: true
      assert_equal 200, response.status
      assert_has_pdf_js response
      assert_match %(btn-generate-pdf), response.body

      doc.pdf.attach(io: load_file("blank.png"), filename: "blank.pdf")
      post doc.to_path("/pdf?check=1"), xhr: true
      assert_equal 200, response.status
      assert_has_pdf_js response
      assert_match %(btn-regenerate-pdf), response.body
      assert_match %(btn-download-pdf), response.body

      post doc.to_path("/pdf"), xhr: true
      assert_equal 200, response.status
      assert_has_pdf_js response
      assert_match %(btn-regenerate-pdf), response.body
      assert_match %(btn-download-pdf), response.body
    end
  end
end
