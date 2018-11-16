# frozen_string_literal: true

# Auto generate with notifications gem.
class Notification < ActiveRecord::Base
  include NotifyTrackable
  include Notifications::Model

  serialize :meta, Hash

  NOTIFY_TYPES = %w[add_member]

  before_create :bind_relation_for_target
  after_commit :create_email_notify, on: [:create]

  def self.allow_type?(notify_type)
    NOTIFY_TYPES.include?(notify_type)
  end

  def self.track_notification(notify_type, target, user: nil, user_id: nil, actor_id: nil, meta: nil)
    notify_type = notify_type.to_s
    return false unless allow_type?(notify_type)

    actor_id ||= Current.user&.id
    return false if actor_id.blank?
    return false if target.blank?

    user_ids = get_user_ids(user: user, user_id: user_id)
    user_ids.delete actor_id

    return false if user_ids.blank?

    notification_params = {
      notify_type: notify_type,
      target: target,
      target_type: target.class.name,
      target_id: target.id,
      actor_id: actor_id,
      meta: meta&.deep_symbolize_keys
    }

    fill_depend_id_for_target(notification_params)

    # create Activity for receivers, for dashboard timeline
    Notification.transaction do
      user_ids.each do |user_id|
        Notification.create!(notification_params.merge(user_id: user_id))
      end
    end
  end

  private
    def bind_relation_for_target
      self.class.fill_depend_id_for_target(self)
    end

    def create_email_notify
      case self.notify_type
      when "add_member"
        UserMailer.with(user: self.user, member: self.target, actor: self.actor).add_member.deliver_later
      end
    end
end
