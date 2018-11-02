# frozen_string_literal: true

class User < ApplicationRecord
  include Slugable

  depends_on :devise, :avatar, :actions, :membership, :search

  has_many :repositories, dependent: :destroy
  has_many :user_actives, -> { order("updated_at desc, id desc") }, dependent: :destroy
  has_many :group_actives, as: :subject, class_name: "UserActive", dependent: :destroy

  validates :name, presence: true, length: { in: 2..20 }
  validates :slug, uniqueness: true

  def to_path(suffix = nil)
    "/#{self.slug}#{suffix}"
  end

  def group?; false; end
  def user?; true; end

  def admin?
    Setting.has_admin?(self.email)
  end
end
