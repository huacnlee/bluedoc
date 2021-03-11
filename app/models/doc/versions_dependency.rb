# frozen_string_literal: true

class Doc
  after_create :track_doc_version_on_create
  after_update :track_doc_version_on_update

  has_many :versions, -> { order("id desc") }, class_name: "DocVersion", as: :subject

  # Revert to a version, this still create a new version
  def revert(version_id, user_id: nil)
    version = versions.find_by_id(version_id)
    if version.blank?
      errors.add(:base, "Revert version is invalid")
      return false
    end

    update(body: version.body_plain, draft_body: version.body_plain, body_sml: version.body_sml, draft_body_sml: version.body_sml, format: version.format, last_editor_id: user_id)
  end

  private

  def track_doc_version_on_create
    _track_doc_version
  end

  def track_doc_version_on_update
    if body.changed? || body_sml.changed?
      _track_doc_version
    end
  end

  def _track_doc_version
    versions.create!(user_id: last_editor_id, body: body, body_sml: body_sml, format: self.format)
  end
end
