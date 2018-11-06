module Memberable
  extend ActiveSupport::Concern

  included do
    has_many :members, as: :subject, dependent: :destroy

    attr_accessor :creator_id

    before_commit :add_creator_as_admin!, on: [:create]
    before_create do
      self.creator_id ||= Current.user.id if Current.user.present?
    end
  end

  def user_role(user)
    return nil if user.blank?
    return nil unless user.user?
    self.members.where(user: user).first&.role&.to_sym
  end

  def has_member?(user)
    self.members.where(user: user).any?
  end

  def add_member(user, role)
    return false if user.blank?
    return false unless user.user?
    self.members.create!(user: user, subject: self, role: role)
  rescue ActiveRecord::RecordNotUnique
    update_member(user, role)
    self.members.where(user: user, subject: self).first
  end

  def update_member(user, role)
    self.members.where(user: user, subject: self).update_all(role: role)
  end

  def remove_member(user)
    self.members.where(user: user).destroy_all
  end

  private

  def add_creator_as_admin!
    return if Current.user.blank?
    self.members.create!(user_id: Current.user.id, subject: self, role: :admin)
  end
end