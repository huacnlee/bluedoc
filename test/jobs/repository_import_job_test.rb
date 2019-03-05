# frozen_string_literal: true

require "test_helper"

class RepositoryImportJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @repo = create(:repository)
    @user = create(:user)
  end

  test "perform with gitbook" do
    create(:repository_source, repository: @repo)
    @repo.reload
    assert_not_nil @repo.source
    mock = Minitest::Mock.new
    mock.expect(:perform, true, [])
    BlueDoc::Import::GitBook.stub(:new, mock) do
      RepositoryImportJob.perform_now(@repo, user: @user, type: "gitbook", url: "git@foo.com")
    end
    mock.verify

    assert_equal 1, Notification.where(notify_type: :repo_import, target: @repo).count
    note = Notification.where(notify_type: :repo_import, target: @repo).last
    assert_equal User.system.id, note.actor_id
    assert_equal @user.id, note.user_id
    assert_equal :success, note.meta[:status]

    assert_equal false, RepositoryImportJob.perform_now(@repo, user: @user, type: "gitbook1", url: "")
  end

  test "perform with archive" do
    mock = Minitest::Mock.new
    @repo.import_archive.attach(io: load_file("archive.zip"), filename: "test.zip")
    mock.expect(:perform, true, [])
    BlueDoc::Import::Archive.stub(:new, mock) do
      RepositoryImportJob.perform_now(@repo, user: @user, type: "archive", url: nil)
    end
    mock.verify

    assert_equal 1, Notification.where(notify_type: :repo_import, target: @repo).count
    note = Notification.where(notify_type: :repo_import, target: @repo).last
    assert_equal User.system.id, note.actor_id
    assert_equal @user.id, note.user_id
    assert_equal :success, note.meta[:status]
  end
end
