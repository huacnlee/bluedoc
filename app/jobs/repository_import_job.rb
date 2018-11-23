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
    ExceptionTrack::Log.create(title: "RepositoryImportJob #{repo.slug} error", body: e)
    Notification.track_notification(:repo_import, repo, user: user, actor_id: User.system.id, meta: { status: :failed, message: e.message })
  end
end
