# frozen_string_literal: true

class RepositoryImportJob < ApplicationJob
  def perform(repo, user:, type:, url:)
    importer = nil
    return false if repo.source.blank?
    case type
    when "gitbook"
      importer = BlueDoc::Import::GitBook.new(repository: repo, user: user, url: url)
    when "archive"
      url = repo.import_archive&.url(expires_in: 10.hours, disposition: :attachment)
      importer = BlueDoc::Import::Archive.new(repository: repo, user: user, url: url)
    else
      return false
    end

    importer.perform

    repo.source.update(status: :done, message: "", retries_count: 0)
    Notification.track_notification(:repo_import, repo, user: user, actor_id: User.system.id, meta: {status: :success})
    true
  rescue => e
    retries_count = (repo.source&.retries_count || 0) + 1
    repo.source.update(status: :failed, message: e.message, retries_count: retries_count)
    BlueDoc::Error.track(e, title: "RepositoryImportJob [#{repo.slug}] #{url} error")
    Notification.track_notification(:repo_import, repo, user: user, actor_id: User.system.id, meta: {status: :failed, message: e.message})
  end
end
