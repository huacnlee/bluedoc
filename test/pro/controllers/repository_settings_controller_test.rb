# frozen_string_literal: true

require "test_helper"

class ProRepositorySettingsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user = create(:user)
    @group = create(:group)
  end

  test "GET /:user/:repo/settings/docs with Export PDF" do
    repo = create(:repository, user: @group)
    docs = create_list(:doc, 10, repository_id: repo.id)

    sign_in_role :admin, group: @group
    get repo.to_path("/settings/docs")
    assert_equal 200, response.status
    assert_select ".export-repository-pdf", 0

    allow_feature(:export_pdf) do
      get repo.to_path("/settings/docs")
      assert_equal 200, response.status

      assert_select ".export-repository-pdf"
    end
  end

  test "GET /:user/:repo/settings/docs with Export Archive" do
    repo = create(:repository, user: @group)
    docs = create_list(:doc, 10, repository_id: repo.id)

    sign_in_role :admin, group: @group
    get repo.to_path("/settings/docs")
    assert_equal 200, response.status
    assert_select ".export-repository-archive", 0

    allow_feature(:export_archive) do
      get repo.to_path("/settings/docs")
      assert_equal 200, response.status

      assert_select ".export-repository-archive"
    end
  end

  test "POST /:user/:repo/settings/export?type=pdf" do
    repo = create(:repository, user: @group)
    assert_require_user do
      post repo.to_path("/settings/export?type=pdf")
    end

    sign_in @user
    assert_check_feature do
      post repo.to_path("/settings/export?type=pdf")
    end

    allow_feature(:export_pdf) do
      post repo.to_path("/settings/export?type=pdf")
      assert_equal 403, response.status

      sign_in_role :editor, group: @group
      post repo.to_path("/settings/export?type=pdf")
      assert_equal 403, response.status

      def assert_has_pdf_js(response)
        assert_match %($(".export-repository-pdf").replaceWith(html);), response.body
      end

      sign_in_role :admin, group: @group
      assert_enqueued_with job: PDFExportJob do
        post repo.to_path("/settings/export?type=pdf&force=1"), xhr: true
      end
      assert_equal 200, response.status
      assert_equal "running", repo.export_pdf_status.value
      assert_has_pdf_js response
      assert_match %(pdf-export-running), response.body
      assert_match %(pdf-export-retry-message), response.body

      # check status
      post repo.to_path("/settings/export?type=pdf&check=1"), xhr: true
      assert_equal 200, response.status
      assert_equal "", response.body.strip

      repo.set_export_status(:pdf, "done")
      post repo.to_path("/settings/export?type=pdf&check=1"), xhr: true
      assert_equal 200, response.status
      assert_has_pdf_js response
      assert_match %(btn-generate-pdf), response.body

      repo.pdf.attach(io: load_file("blank.png"), filename: "blank.pdf")
      post repo.to_path("/settings/export?type=pdf&check=1"), xhr: true
      assert_equal 200, response.status
      assert_has_pdf_js response
      assert_match %(btn-regenerate-pdf), response.body
      assert_match %(btn-download-pdf), response.body

      post repo.to_path("/settings/export?type=pdf"), xhr: true
      assert_equal 200, response.status
      assert_has_pdf_js response
      assert_match %(btn-regenerate-pdf), response.body
      assert_match %(btn-download-pdf), response.body
    end
  end

  test "POST /:user/:repo/settings/export?type=archive" do
    repo = create(:repository, user: @group)
    assert_require_user do
      post repo.to_path("/settings/export?type=archive")
    end

    sign_in @user
    assert_check_feature do
      post repo.to_path("/settings/export?type=archive")
    end

    allow_feature(:export_archive) do
      post repo.to_path("/settings/export?type=archive")
      assert_equal 403, response.status

      sign_in_role :editor, group: @group
      post repo.to_path("/settings/export?type=archive")
      assert_equal 403, response.status

      def assert_has_archive_js(response)
        assert_match %($(".export-repository-archive").replaceWith(html);), response.body
      end

      sign_in_role :admin, group: @group
      assert_enqueued_with job: ArchiveExportJob do
        post repo.to_path("/settings/export?type=archive&force=1"), xhr: true
      end
      assert_equal 200, response.status
      assert_equal "running", repo.export_archive_status.value
      assert_has_archive_js response
      assert_match %(archive-export-running), response.body
      assert_match %(archive-export-retry-message), response.body

      # check status
      post repo.to_path("/settings/export?type=archive&check=1"), xhr: true
      assert_equal 200, response.status
      assert_equal "", response.body.strip

      repo.set_export_status(:archive, "done")
      post repo.to_path("/settings/export?type=archive&check=1"), xhr: true
      assert_equal 200, response.status
      assert_has_archive_js response
      assert_match %(btn-generate-archive), response.body

      repo.archive.attach(io: load_file("blank.png"), filename: "blank.zip")
      post repo.to_path("/settings/export?type=archive&check=1"), xhr: true
      assert_equal 200, response.status
      assert_has_archive_js response
      assert_match %(btn-regenerate-archive), response.body
      assert_match %(btn-download-archive), response.body

      post repo.to_path("/settings/export?type=archive"), xhr: true
      assert_equal 200, response.status
      assert_has_archive_js response
      assert_match %(btn-regenerate-archive), response.body
      assert_match %(btn-download-archive), response.body
    end
  end
end