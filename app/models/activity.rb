# frozen_string_literal: true

class Activity < ApplicationRecord
  include NotifyTrackable

  belongs_to :user, required: false
  belongs_to :actor, class_name: "User"
  belongs_to :target, polymorphic: true

  serialize :meta, Hash

  ACTIONS = %w[star_repo star_doc star_note follow_user create_repo update_repo transfer_repo create_doc update_doc add_member]
  NO_ACTOR_ACTIONS = %w[add_member]

  def self.action_to_actor?(action)
    !NO_ACTOR_ACTIONS.include?(action.to_s)
  end

  def self.track_activity(action, target, user: nil, user_id: nil, actor_id: nil, meta: nil, unique: true)
    action = action.to_s
    return false unless ACTIONS.include?(action)

    actor_id ||= Current.user&.id
    return false if actor_id.blank?

    user_ids = get_user_ids(user: user, user_id: user_id)
    user_ids.delete actor_id

    activity_params = {
      action: action,
      target: target,
      target_type: target.class.name,
      target_id: target.id,
      actor_id: actor_id,
      meta: meta&.deep_symbolize_keys,
      created_at: Time.now,
      updated_at: Time.now
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
    Activity.create!(activity_params) if action_to_actor?(action)

    records = []
    activity_params.delete(:target)
    user_ids.each do |uid|
      records << activity_params.merge(user_id: uid)
    end

    # create Activity for receivers, for dashboard timeline
    records.each_slice(100) do |parts|
      Activity.insert_all(parts)
    end
  end
end
