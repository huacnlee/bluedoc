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
    @toc_html ||= Rails.cache.fetch([cache_key_with_version, "toc_html", "v1", prefix]) do
      BlueDoc::Toc.parse(toc_text).to_html(prefix: prefix)
    end
  end

  def toc_text
    return toc&.body if toc.present?
    toc_by_docs_text
  end

  def toc_by_docs_text
    Rails.cache.fetch([cache_key_with_version, "toc_by_docs_text"]) do
      lines = []
      docs.order("id asc").each do |doc|
        lines << { title: doc.title, depth: 0, id: doc.id, url: doc.slug }.as_json
      end
      lines.to_yaml
    end
  end

  def toc_json
    BlueDoc::Toc.parse(toc_text).to_json
  end

  def toc_by_docs_json
    BlueDoc::Toc.parse(toc_by_docs_text).to_json
  end

  # sort docs as Toc order
  def toc_ordered_docs
    return @toc_ordered_docs if defined? @toc_ordered_docs

    # parse Toc and collect urls
    ordered_urls = BlueDoc::Toc.parse(toc_text).items.collect(&:url)
    ordered_urls.compact!
    ordered_urls.map { |url| url.strip! }

    # pickup docs as a slug key hash
    doc_hash = {}
    self.docs.map { |doc| doc_hash[doc.slug] = doc }

    # pickup docs by Toc ordered, and ignore it not exist in Toc
    ordered_docs = []
    ordered_urls.each do |toc_url|
      ordered_docs << doc_hash[toc_url] if doc_hash.has_key?(toc_url)
    end
    @toc_ordered_docs = ordered_docs
  end

  # update title by slug
  #
  #   repo.update_toc_by_url("hello", title: "New title", url: "new-slug")
  #
  def update_toc_by_url(url, params = {})
    # lock toc before update
    locker = Redis::Lock.new("#{self.cache_key}/update-toc", expiration: 2, timeout: 5)
    locker.lock do
      content = BlueDoc::Toc.parse(toc_text)
      item = content.find_by_url(url)
      return false if item.blank?

      item.title = params[:title] if params[:title]
      item.url = params[:url] if params[:url]

      self.update!(toc: content.to_yaml)
    end
  end

  # Ordered docs list for read way
  # when has toc?
  #  => return docs by toc ordered
  # otherwise
  #  => return by id asc
  def read_ordered_docs
    return @read_ordered_docs if defined? @read_ordered_docs
    @read_ordered_docs = has_toc? ? toc_ordered_docs : self.docs.order("id asc").all
    @read_ordered_docs
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
      BlueDoc::Toc.parse(toc_text, strict: true).to_html
    rescue BlueDoc::Toc::FormatError => e
      errors.add(:toc, "Invalid TOC format (required YAML format).")
    rescue => e
      errors.add(:toc, "Parse error: #{e.message}")
    end
end
