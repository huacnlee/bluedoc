# frozen_string_literal: true

class RepositoryImportJob < ApplicationJob
  def perform(repo, user:, type:, url:)
    importer = nil
    if type == "gitbook"
      importer = BookLab::Import::GitBook.new(repository: repo, user: user, url: url)
    end

    importer.perform

    Notification.track_notification(:repo_import, repo, user: user, actor_id: User.system.id, meta: { status: :success })
  rescue => e
    BookLab::Error.track(e, title: "RepositoryImportJob [#{repo.slug}] #{url} error")
    Notification.track_notification(:repo_import, repo, user: user, actor_id: User.system.id, meta: { status: :failed, message: e.message })
  end
end
