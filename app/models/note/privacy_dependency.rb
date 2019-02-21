# frozen_string_literal: true

class Note
  enum privacy: %i(private public), _prefix: :is
  scope :publics, -> { where(privacy: :public) }

  before_update :check_on_make_private

  def private?
    self.is_private?
  end

  def public?
    self.is_public?
  end

  private

    def check_on_make_private
      if self.privacy_changed? && self.private?
        self.destroy_depend_activities

        # FIXME: Remove depends actions
      end
    end
end
