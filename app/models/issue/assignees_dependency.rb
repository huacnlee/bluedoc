class Issue
  has_many :issue_assignees
  has_many :assignees, class_name: "User", through: :issue_assignees, source: :user

  # Users that for assignee
  def assignee_target_users
    user_ids = repository.members.pluck(:user_id)
    user_ids += repository.user.members.pluck(:user_id)
    User.where(id: user_ids.uniq).with_attached_avatar
  end

  # Replace issue assignees
  def update_assignees(assignee_ids)
    self.assignee_ids = assignee_ids
    self.save
  end
end