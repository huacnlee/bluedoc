# frozen_string_literal: true

class Issue
  has_many :issue_assignees
  has_many :assignees, class_name: "User", through: :issue_assignees, source: :user

  scope :with_assignees, ->(ids) do
    ids = Array(ids).collect(&:to_i).uniq
    joins(:issue_assignees).where("issue_assignees.user_id in (?)", ids) if ids.any?
  end

  # Replace issue assignees
  def update_assignees(assignee_ids)
    assignee_ids = assignee_ids.uniq
    # New assignee will ignore exists users and current_user
    new_assignee_ids = assignee_ids - self.assignee_ids - [Current.user&.id]

    self.assignee_ids = assignee_ids
    if save
      new_assignee_ids.each do |user_id|
        User.create_action(:watch_comment, target: self, user_type: "User", user_id: user_id)
        UserActive.track(self, user_id: user_id)
      end

      NotificationJob.perform_later "issue_assign", self, user_id: new_assignee_ids, actor_id: Current.user&.id
    end
  end
end
