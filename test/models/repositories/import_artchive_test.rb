# frozen_string_literal: true

require "test_helper"

class RepositoryImportArchiveTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "import Zip Archive" do
    repo = create(:repository)
    repo.import_archive.attach(io: load_file("archive.zip"), filename: "archive.zip")
    repo.send(:save_source_url)
    repo.import_from_source
    assert_enqueued_jobs 1, only: RepositoryImportJob
    assert_equal false, repo.new_record?

    repo.source.reload

    assert_not_nil repo.source
    assert_equal true, repo.source?
    assert_equal repo.import_archive.blob.key, repo.source.url
    assert_equal "archive", repo.source.provider
    assert_not_nil repo.source.job_id

    old_job_id = repo.source_job_id

    assert_equal repo.import_archive.blob.key, repo.source_url
    assert_equal "archive", repo.source_provider
    assert_equal repo.source.job_id, repo.source_job_id

    repo.import_from_source
    assert_enqueued_jobs 2, only: RepositoryImportJob
    assert_not_equal old_job_id, repo.source_job_id

    repo.destroy
    assert_equal 0, RepositorySource.where(repository: repo).count
  end
end