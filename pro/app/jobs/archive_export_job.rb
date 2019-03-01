# frozen_string_literal: true

class ArchiveExportJob < ApplicationJob
  def perform(repo)
    check_feature! :export_pdf

    return nil if repo.blank?
    return nil unless repo.is_a?(Repository)

    exporter = BlueDoc::Export::Archive.new(repository: repo)
    exporter.perform
  rescue => e
    BlueDoc::Error.track(e, title: "ArchiveExportJob [repo #{repo.slug}] error")
  ensure
    repo.set_export_status(:archive, "done")
  end
end
