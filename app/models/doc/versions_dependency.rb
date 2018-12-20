# frozen_string_literal: true

class Doc
  after_create :track_doc_version_on_create
  after_update :track_doc_version_on_update

  has_many :versions, -> { order("id desc") }, class_name: "DocVersion", as: :subject

  # Revert to a version, this still create a new version
  def revert(version_id, user_id: nil)
    version = self.versions.find_by_id(version_id)
    if version.blank?
      errors.add(:base, "Revert version is invalid")
      return false
    end

    self.update(body: version.body_plain, body_sml: version.body_sml, format: version.format, last_editor_id: user_id)
  end

  private

    def track_doc_version_on_create
      _track_doc_version
    end

    def track_doc_version_on_update
      if self.body.changed? || self.body_sml.changed?
        _track_doc_version
      end
    end

    def _track_doc_version
      self.versions.create!(user_id: self.last_editor_id, body: self.body, body_sml: self.body_sml, format: self.format)
    end
end
