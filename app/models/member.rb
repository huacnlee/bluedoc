# frozen_string_literal: true

class Member < ApplicationRecord
  include SoftDelete
  include Activityable

  depends_on :user_actives, :activities, :notifications

  second_level_cache expires_in: 1.week

  enum role: %i(admin editor reader)

  belongs_to :user, required: false
  belongs_to :subject, required: false, polymorphic: true, counter_cache: true

  def role_name
    self.class.role_name(role)
  end

  def self.role_options
    roles.keys.map { |key| [I18n.t("member_role.#{key}"), key] }
  end

  def self.role_name(role)
    I18n.t("member_role.#{role}")
  end
end
