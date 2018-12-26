# frozen_string_literal: true

class RepositoryImportJob < ApplicationJob
  def perform(repo, user:, type:, url:)
    importer = nil

    case type
    when "gitbook"
      importer = BookLab::Import::GitBook.new(repository: repo, user: user, url: url)
    when "archive"
      url = repo.import_archive&.service_url
      importer = BookLab::Import::Archive.new(repository: repo, user: user, url: url)
    else
      return false
    end

    importer.perform

    Notification.track_notification(:repo_import, repo, user: user, actor_id: User.system.id, meta: { status: :success })
  rescue => e
    BookLab::Error.track(e, title: "RepositoryImportJob [#{repo.slug}] #{url} error")
    Notification.track_notification(:repo_import, repo, user: user, actor_id: User.system.id, meta: { status: :failed, message: e.message })
  end
end
