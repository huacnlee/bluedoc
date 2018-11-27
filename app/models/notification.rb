# frozen_string_literal: true

# Auto generate with notifications gem.
class Notification < ActiveRecord::Base
  include NotifyTrackable
  include Notifications::Model

  delegate :email, to: :user
  delegate :name, to: :actor, prefix: true, allow_nil: true

  serialize :meta, Hash

  NOTIFY_TYPES = %w[add_member repo_import comment mention]

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
        note = Notification.new(notification_params)
        note.user_id = user_id

        # ingore create, if user not has ability to read target
        ability = Ability.new(User.new(id: user_id))
        next if ability.cannot?(:read, note.target)

        note.save!
      end
    end
  end

  # mark target_type, target_ids as read
  def self.read_targets(user, target_type:, target_id:)
    return if user.blank?
    Notification.where(user: user, target_type: target_type, target_id: target_id).update_all(read_at: Time.now)
  end

  def target_url
    case notify_type
    when "add_member" then self.target&.subject&.to_url
    when "repo_import" then self.target&.to_url
    when "comment" then self.target&.to_url
    when "mention" then self.target&.to_url
    else
      return Setting.host
    end
  end

  def mail_body
    ApplicationController.renderer.render "/notifications/body/#{notify_type}", layout: false, locals: { notification: self }
  rescue
    ApplicationController.renderer.render "/notifications/title/#{notify_type}", layout: false, locals: { notification: self }
  end

  def mail_title
    html = ApplicationController.renderer.render "/notifications/title/#{notify_type}", layout: false, locals: { notification: self }
    html.gsub(/<.+?>/, "").gsub(/\s+/, " ").strip
  end

  # comment-doc-id
  def mail_message_id
    message_ids = [self.notify_type]

    case self.notify_type
    when "comment"
      message_ids += [self.target&.commentable_type, self.target&.commentable_id]
    when "add_member"
      message_ids += [self.target&.subject_type, self.target&.subject_id]
    when "mention"
      case self.target_type
      when "Comment"
        message_ids = ["comment", self.target&.commentable_type, self.target&.commentable_id]
      else
        message_ids = ["comment", self.target_type, self.target_id]
      end
    else
      message_ids += [self.target_type, self.target_id]
    end

    message_ids.join("-")
  end

  private
    def bind_relation_for_target
      self.class.fill_depend_id_for_target(self)
    end

    def create_email_notify
      NotificationMailer.with(notification: self).to_user.deliver_later
    end
end
