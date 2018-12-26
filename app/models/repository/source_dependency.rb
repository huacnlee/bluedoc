# frozen_string_literal: true

require "sidekiq/api"

class Repository
  has_one :source, class_name: "RepositorySource", autosave: true, dependent: :destroy

  delegate :provider, to: :source, allow_nil: true, prefix: true
  delegate :url, to: :source, allow_nil: true, prefix: true
  delegate :job_id, to: :source, allow_nil: true, prefix: true

  has_one_attached :import_archive

  attr_accessor :gitbook_url

  before_validation :validate_gitbook_url
  after_save :save_source_url
  after_commit :import_from_source, on: [:create]

  def gitbook_url
    return @gitbook_url if defined? @gitbook_url
    return nil if self.source_provider != "gitbook"
    @gitbook_url = self.source_url
    @gitbook_url
  end

  def validate_gitbook_url
    if !gitbook_url.blank? && !BookLab::Validate.url?(gitbook_url)
      self.errors.add(:gitbook_url, "is not a valid Git url, only support HTTP/HTTPS git url")
    end
  end

  def source?
    @sourced ||= self.source_url.present?
  end

  def import_from_source
    return if self.source.blank?

    job = RepositoryImportJob.perform_later(self, type: self.source_provider, user: Current.user, url: self.source_url)
    self.source.update(job_id: job.job_id) if job
  end

  private

    def save_source_url
      if self.gitbook_url.present?
        self.source ||= RepositorySource.new(repository: self)
        self.source.provider = "gitbook"
        self.source.url = self.gitbook_url
        self.source.save!
      elsif self.import_archive.attached?
        self.source ||= RepositorySource.new(repository: self)
        self.source.provider = "archive"
        self.source.url = self.import_archive.blob.key
        self.source.save!
      end
    end
end
