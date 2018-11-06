module Activityable
  extend ActiveSupport::Concern

  included do
    after_commit :destroy_depend_activities, on: [:destroy]
  end

  private

    def destroy_depend_activities
      # TODO: execute as async
      case self.class.name
      when "Group"
        Activity.where(group_id: self.id).destroy_all
      when "User"
        if self.type == "Group"
          Activity.where(group_id: self.id).destroy_all
        else
          Activity.where(user_id: self.id).destroy_all
          Activity.where(actor_id: self.id).destroy_all
        end
      when "Repository"
        Activity.where(repository_id: self.id).destroy_all
      end

      Activity.where(target: self).destroy_all
    end
end