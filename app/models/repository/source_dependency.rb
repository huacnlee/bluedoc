# frozen_string_literal: true

require "sidekiq/api"

class Repository
  has_one :source, class_name: "RepositorySource", autosave: true, dependent: :destroy

  delegate :provider, to: :source, allow_nil: true, prefix: true
  delegate :url, to: :source, allow_nil: true, prefix: true
  delegate :job_id, to: :source, allow_nil: true, prefix: true

  attr_accessor :gitbook_url

  after_save :save_source_url
  after_commit :import_from_source, on: [:create]

  def gitbook_url
    return @gitbook_url if defined? @gitbook_url
    return nil if self.source_provider != "gitbook"
    @gitbook_url = self.source_url
    @gitbook_url
  end

  def source?
    @sourced ||= self.source_url.present?
  end

  def import_from_source
    job = nil
    case self.source_provider
    when "gitbook"
      job = RepositoryImportJob.perform_later(self, type: "gitbook", user: Current.user, url: self.source_url)
    end

    self.source.update(job_id: job.job_id) if job
  end

  private

    def save_source_url
      if self.gitbook_url.present?
        self.source ||= RepositorySource.new(repository: self)
        self.source.provider = "gitbook"
        self.source.url = self.gitbook_url
        self.source.save!
      end
    end
end