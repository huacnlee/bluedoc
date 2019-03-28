class Issue
  scope :with_assignees, -> (ids) { ids.any? ? where("ARRAY[?] <@ assignee_ids", ids) : all }

  # Users that for assignee
  def assignee_target_users
    user_ids = repository.members.pluck(:user_id)
    user_ids += repository.user.members.pluck(:user_id)
    users = User.where(id: user_ids.uniq).with_attached_avatar
    users.sort_by { |user| user_ids.index(user.id) }
  end

  # Replace issue assignees
  def update_assignees(assignee_ids)
    self.assignee_ids = assignee_ids.uniq
    self.save
  end

  def assignees
    User.where(id: self.assignee_ids)
  end
end