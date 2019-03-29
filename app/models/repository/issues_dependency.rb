# frozen_string_literal: true

class Repository
  has_many :issues, dependent: :destroy
  has_many :issue_labels, as: :target, dependent: :destroy, class_name: "Label"

  def has_issues?
    return true if self.preferences[:has_issues].nil?
    ActiveModel::Type::Boolean.new.cast(self.preferences[:has_issues])
  end

  DEFAULT_ISSUE_LABELS = {
    discussion: "#3070ff",
    question: "#d62800",
    support: "#00a505",
    invalid: "#6f42c1",
    duplicate: "#008080",
    wontfix: "#5a5a5a"
  }

  def ensure_default_issue_labels
    return false if self.issue_labels.any?
    create_default_issue_labels!
  end

  def create_default_issue_labels!
    Label.transaction do
      DEFAULT_ISSUE_LABELS.each_key do |name|
        Label.create!(target: self, title: name.to_s.titleize, color: DEFAULT_ISSUE_LABELS[name])
      end
    end
  end

  # Users that for issue assignee
  def issue_assignees
    user_ids = self.members.pluck(:user_id)
    user_ids += self.user.members.pluck(:user_id)
    users = User.where(id: user_ids.uniq).with_attached_avatar
    users.sort_by { |user| user_ids.index(user.id) }
  end
end
