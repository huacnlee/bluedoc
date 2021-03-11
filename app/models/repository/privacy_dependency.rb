# frozen_string_literal: true

class Repository
  enum privacy: %i[private public], _prefix: :is

  scope :publics, -> { where(privacy: :public) }

  before_update :check_on_make_private

  def private?
    is_private?
  end

  def public?
    is_public?
  end

  private

  def check_on_make_private
    if privacy_changed? && private?
      destroy_depend_activities
    end
  end
end
