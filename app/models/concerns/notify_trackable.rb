module NotifyTrackable
  extend ActiveSupport::Concern

  class_methods do
    def fill_depend_id_for_target(notify_params)
      target = notify_params[:target]

      case target.class.name
      when "Group"
        notify_params[:group_id] = target.id
      when "Repository"
        notify_params[:group_id] = target.user_id
        notify_params[:repository_id] = target.id
      when "Doc"
        notify_params[:repository_id] = target.repository_id
        notify_params[:group_id] = target.repository&.user_id
      when "Member"
        subject = target.subject
        case target.subject_type
        when "Group"
        when "User"
          notify_params[:group_id] = subject.id
        when "Repository"
          notify_params[:group_id] = subject.user_id
          notify_params[:repository_id] = subject.id
        end
      end
    end

    def get_user_ids(user: nil, user_id: nil)
      user_ids = []
      if user_id.is_a?(Array)
        user_ids = user_id
      else
        user_ids = [user_id] if !user_id.blank?
      end

      if user.is_a?(Array)
        users = user
      else
        users = [user] if !user.blank?
      end

      user_ids = users.map(&:id) if users.present?
      user_ids.uniq!
      user_ids
    end
  end
end