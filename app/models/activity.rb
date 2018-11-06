class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: "User"
  belongs_to :target, polymorphic: true

  serialize :meta, Hash

  ACTIONS = %w[star_repo follow_user create_repo update_repo create_doc update_doc]

  def self.track_activity(action, target, user:, meta: nil)
    return false unless ACTIONS.include?(action.to_s)
    users = user
    users = [user] if !user.is_a?(Array)

    activity_params = {
      action: action,
      target: target,
      actor: Current.user
    }

    fill_depend_id_for_target(activity_params)

    Activity.transaction do
      users.each do |user|
        Activity.create!(activity_params.merge(user: user))
      end
    end
  end

  def self.fill_depend_id_for_target(activity_params)
    target = activity_params[:target]

    case target.class.name
    when "Group"
      activity_params[:group_id] = target.id
    when "Repository"
      activity_params[:group_id] = target.user_id
      activity_params[:repository_id] = target.id
    when "Doc"
      activity_params[:repository_id] = target.repository_id
      activity_params[:group_id] = target.repository&.user_id
    when "Member"
      subject = target.subject
      case target.subject_type
      when "Group"
      when "User"
        activity_params[:group_id] = subject.id
      when "Repository"
        activity_params[:group_id] = subject.user_id
        activity_params[:repository_id] = subject.id
      end
    end
  end
end
