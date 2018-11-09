# frozen_string_literal: true

class RepositoryImportJob < ApplicationJob
  def perform(repository, user:, type:, url:)
    importer = nil

    if type == "gitbook"
      importer = BookLab::Import::GitBook.new(repository: repository, user: user, git_url: url)
    end

    importer&.perform
  end
end
