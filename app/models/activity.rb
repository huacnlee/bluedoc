class Activity < ApplicationRecord
  belongs_to :user, required: false
  belongs_to :actor, class_name: "User"
  belongs_to :target, polymorphic: true

  serialize :meta, Hash

  ACTIONS = %w[star_repo follow_user create_repo update_repo transfer_repo create_doc update_doc]

  def self.track_activity(action, target, user: nil, user_id: nil, actor_id: nil, meta: nil, unique: true)
    return false unless ACTIONS.include?(action.to_s)

    actor_id ||= Current.user&.id
    return false if actor_id.blank?

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

    if users.present?
      user_ids = users.map(&:id)
    end
    user_ids.uniq!

    activity_params = {
      action: action,
      target: target,
      target_type: target.class.name,
      target_id: target.id,
      actor_id: actor_id,
      meta: meta&.deep_symbolize_keys
    }

    fill_depend_id_for_target(activity_params)

    # clean first if unique: true
    if unique
      Activity.transaction do
        Activity.where(action: action, actor_id: actor_id, user_id: nil, target_type: activity_params[:target_type], target_id: activity_params[:target_id]).delete_all
        Activity.where(action: action, actor_id: actor_id, user_id: user_ids, target_type: activity_params[:target_type], target_id: activity_params[:target_id]).delete_all
      end
    end

    # create Activity for actor, for display on user profile page
    Activity.create!(activity_params)

    if activity_params[:meta]
      # bulk_insert must convert serialize field to String
      activity_params[:meta] = YAML.dump(activity_params[:meta])
    end

    # create Activity for receivers, for dashboard timeline
    Activity.bulk_insert(set_size: 100) do |worker|
      user_ids.each do |user_id|
        worker.add(activity_params.merge(user_id: user_id))
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
