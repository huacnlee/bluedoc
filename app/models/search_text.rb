# frozen_string_literal: true

class SearchText < ApplicationRecord
  include PgSearch

  belongs_to :record, polymorphic: true
  belongs_to :repository, required: false
  belongs_to :user, required: false

  pg_search_scope :fulltext_search,
    against: %i(body),
    using: {
      tsearch: {
        dictionary: :english,
        highlight: {
          StartSel: '{{b}}',
          StopSel: '{{/b}}',
          FragmentDelimiter: '&hellip;',
          MaxWords: 10,
          MinWords: 8
        }
      }
    }

  def self.search(type, q)
    q ||= BookLab::Search.prepare_data(q || "", :mix).strip
    logger.info "[search] #{q.inspect}"
    items = self.where(record_type: type.to_s.classify).fulltext_search(q)

    case type.to_sym
    when :docs
      items = items.joins(:repository).where("repositories.privacy = ?", Repository.privacies[:public])
    when :repositories
      items = items.joins(:repository).where("repositories.privacy = ?", Repository.privacies[:public])
    end

    items
  end

  # cleanup
  def self.destroy_index(record)
    self.where(record: record).delete_all
    self.where(repository_id: record.id).delete_all if record.is_a?(Repository)
    self.where(user_id: record.id).delete_all if record.is_a?(User) || record.is_a?(Group)
  end

  def self.reindex(record)
    record_type = record.class.name
    record_id = record.id

    if record_type == "User"
      if record.group?
        record_type = "Group"
      end
    end

    item ||= self.find_or_create_by!(record_type: record_type, record_id: record_id)

    case record_type
    when "Doc"
      item.title = record.title
      item.slug = record.slug
      item.body = record.body_plain
      item.repository_id = record.repository_id
      item.user_id = record.repository&.user_id
    when "Repository"
      item.title = record.name
      item.slug = record.slug
      item.body = record.description
      item.repository_id = record.id
      item.user_id = record.user_id
    when "Group", "User"
      item.title = record.name
      item.slug = record.slug
      item.body = record.description
      item.user_id = record.id
    else
      return nil
    end

    item.title = BookLab::Search.prepare_data(item.title || "")
    item.body = BookLab::Search.prepare_data(item.body || "")

    item.save!
    item
  end
end
