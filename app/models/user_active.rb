class UserActive < ApplicationRecord
  belongs_to :subject, polymorphic: true, required: false
  belongs_to :user, required: false

  default_scope -> { order("updated_at desc, id desc")  }
  scope :with_user, -> (user) { where(user_id: user.id) }
  scope :docs, -> { where(subject_type: "Doc").includes(subject: { repository: :user }) }
  scope :repositories, -> { where(subject_type: "Repository").includes(subject: :user) }
  scope :groups, -> { where(subject_type: "User").includes(subject: { avatar_attachment: :blob }) }

  def self.track(subject, user_id: nil, user: nil)
    return false if subject.blank?

    user_id = user.id if user
    return false if user_id.blank?

    # avoid track User type, only Group
    if subject.is_a?(User) && !subject.group?
      return false
    end

    user_action = where(user_id: user_id, subject: subject).first
    if user_action
      raise ActiveRecord::RecordNotUnique.new("Exist")
    end

    create!(user_id: user_id, subject: subject)
  rescue ActiveRecord::RecordNotUnique
    where(user_id: user_id, subject: subject).update_all(updated_at: Time.now)
  end
end
