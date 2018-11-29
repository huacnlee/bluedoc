# frozen_string_literal: true

class Repository
  has_rich_text :toc

  has_many :toc_versions, -> { order("id desc") }, class_name: "TocVersion", as: :subject

  after_create :track_doc_version_on_create
  after_update :track_doc_version

  def has_toc?
    ActiveModel::Type::Boolean.new.cast(self.preferences[:has_toc])
  end

  validate :lint_toc_format

  def toc_html(prefix: nil)
    @toc_html ||= Rails.cache.fetch([cache_key_with_version, "toc_html", prefix]) do
      BookLab::Toc.parse(toc_text).to_html(prefix: prefix)
    end
  end

  def toc_text
    return toc&.body&.to_plain_text if toc.present?

    Rails.cache.fetch([cache_key_with_version, "toc_text"]) do
      lines = []
      docs.order("id asc").each do |doc|
        lines << { title: doc.title, depth: 0, id: doc.id, url: doc.slug }.as_json
      end
      lines.to_yaml
    end
  end

  def toc_json
    BookLab::Toc.parse(toc_text).to_json
  end

  private

    def track_doc_version_on_create
      return unless self.toc.present?
      self.toc_versions.create!(user_id: self.last_editor_id, body: self.toc)
    end

    def track_doc_version
      return unless self.toc.changed?

      self.toc_versions.create(user_id: self.last_editor_id, body: self.toc)
    end

    def lint_toc_format
      BookLab::Toc.parse(toc_text, strict: true).to_html
    rescue BookLab::Toc::FormatError => e
      errors.add(:toc, "Invalid TOC format (required YAML format).")
    rescue => e
      errors.add(:toc, "Parse error: #{e.message}")
    end
end
