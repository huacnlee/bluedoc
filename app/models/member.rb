# frozen_string_literal: true

class Member < ApplicationRecord
  include SoftDelete
  include Activityable

  depends_on :user_actives, :activities, :notifications

  second_level_cache expires_in: 1.week

  enum role: %i(admin editor reader)

  belongs_to :user, required: false
  belongs_to :subject, required: false, polymorphic: true, counter_cache: true
end
