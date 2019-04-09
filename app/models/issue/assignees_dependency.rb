# frozen_string_literal: true

class Issue
  # has_and_belongs_to_many :assignees, join_table: :users, class_name: "User", foreign_key: :assignee_ids
  scope :with_assignees, -> (ids) do
    ids = [ids] unless ids.is_a?(Array)
    ids = ids.collect { |id| id.to_i }
    ids.any? ? where("ARRAY[?] <@ assignee_ids", ids) : all
  end

  # Replace issue assignees
  def update_assignees(assignee_ids)
    self.assignee_ids = assignee_ids.uniq
    if self.save
      self.assignee_ids.each do |user_id|
        User.create_action(:watch_comment, target: self, user_type: "User", user_id: user_id)
      end
    end
  end

  def assignees
    return @assignees if defined? @assignees

    records = User.where(id: self.assignee_ids)
    records.sort_by { |u| self.assignee_ids.index(u.id) }
  end

  def assignees=(val)
    @assignees = val
  end

  class << self
    def preload_assignees
      assignee_ids = all.collect(&:assignee_ids).flatten.compact
      users = User.where(id: assignee_ids)
      records = all
      records.each do |item|
        item.assignees = users.select { |u| item.assignee_ids.include?(u.id) }
      end
      records
    end
  end
end
