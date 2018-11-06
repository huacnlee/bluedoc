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

    Activity.transaction do
      users.each do |user|
        Activity.create!(action: action, target: target, user: user, actor: Current.user)
      end
    end
  end
end
