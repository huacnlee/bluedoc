# frozen_string_literal: true

require "test_helper"

class RepositoryImportGitbookTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "import GitBook" do
    repo = build(:repository, gitbook_url: nil)
    assert_equal true, repo.valid?

    repo = build(:repository, gitbook_url: "git://foo.com")
    assert_equal false, repo.valid?
    assert_equal ["is not a valid Git url, only support HTTP/HTTPS git url"], repo.errors[:gitbook_url]

    url = "https://hello"
    repo = create(:repository, gitbook_url: url)
    assert_enqueued_jobs 1, only: RepositoryImportJob
    assert_equal false, repo.new_record?

    repo.source.reload

    assert_not_nil repo.source
    assert_equal true, repo.source?
    assert_equal url, repo.source.url
    assert_equal "gitbook", repo.source.provider
    assert_not_nil repo.source.job_id

    old_job_id = repo.source_job_id

    assert_equal url, repo.gitbook_url
    assert_equal url, repo.source_url
    assert_equal "gitbook", repo.source_provider
    assert_equal repo.source.job_id, repo.source_job_id

    repo.gitbook_url = "https://bar.foo"
    assert_equal "https://bar.foo", repo.gitbook_url
    assert_equal true, repo.save
    assert_equal "https://bar.foo", repo.gitbook_url
    assert_equal "https://bar.foo", repo.source_url

    repo.import_from_source
    assert_enqueued_jobs 2, only: RepositoryImportJob
    assert_not_equal old_job_id, repo.source_job_id

    repo.destroy
    assert_equal 0, RepositorySource.where(repository: repo).count
  end
end