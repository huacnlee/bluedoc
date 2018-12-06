# frozen_string_literal: true

class Repository
  include Editorable

  before_save :track_editor_on_toc_update

  private

    def track_editor_on_toc_update
      return unless self.toc.changed?

      self.add_editor(Current.user&.id)
    end
end
