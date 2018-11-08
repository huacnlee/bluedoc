module Activityable
  extend ActiveSupport::Concern

  included do
    after_commit :destroy_depend_activities, on: [:destroy]
  end

  def destroy_depend_activities
    case self.class.name
    when "Group"
      Activity.where(group_id: self.id).delete_all
    when "User"
      if self.type == "Group"
        Activity.where(group_id: self.id).delete_all
      else
        Activity.where(user_id: self.id).delete_all
        Activity.where(actor_id: self.id).delete_all
      end
    when "Repository"
      Activity.where(repository_id: self.id).delete_all
    end

    Activity.where(target: self).delete_all
  end
end