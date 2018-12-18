# frozen_string_literal: true

module Activityable
  extend ActiveSupport::Concern

  included do
    after_destroy :destroy_depend_activities
  end

  def destroy_depend_activities
    case self.class.name
    when "Group"
      Activity.where(group_id: self.id).delete_all
      Notification.where(group_id: self.id).delete_all
    when "User"
      if self.type == "Group"
        Activity.where(group_id: self.id).delete_all
        Notification.where(group_id: self.id).delete_all
      else
        Activity.where(user_id: self.id).delete_all
        Notification.where(user_id: self.id).delete_all
        Activity.where(actor_id: self.id).delete_all
        Notification.where(actor_id: self.id).delete_all
      end
    when "Repository"
      Activity.where(repository_id: self.id).delete_all
      Notification.where(repository_id: self.id).delete_all
    end

    Activity.where(target: self).delete_all
    Notification.where(target: self).delete_all
  end
end
