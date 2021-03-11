# frozen_string_literal: true

class Issue
  # has_and_belongs_to_many :assignees, join_table: :users, class_name: "User", foreign_key: :assignee_ids
  scope :with_labels, ->(ids) do
    ids = [ids] unless ids.is_a?(Array)
    ids = ids.collect { |id| id.to_i }
    ids.any? ? where("ARRAY[?] <@ label_ids", ids) : all
  end

  # Replace issue assignees
  def update_labels(label_ids)
    self.label_ids = label_ids.uniq
    save
  end

  def labels
    return @labels if defined? @labels

    records = repository.issue_labels.where(id: label_ids)
    records.sort_by { |record| label_ids.index(record.id) }
  end

  attr_writer :labels

  class << self
    def preload_labels
      label_ids = all.collect(&:label_ids).flatten.compact
      labels = Label.where(id: label_ids)
      records = all
      records.each do |item|
        item.labels = labels.select { |u| item.label_ids.include?(u.id) }
      end
      records
    end
  end
end
