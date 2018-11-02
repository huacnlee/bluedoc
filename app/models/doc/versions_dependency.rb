class Doc
  after_create :track_doc_version_on_create
  after_update :track_doc_version

  has_many :versions, -> { order("id desc") }, class_name: "DocVersion", as: :subject


  # Revert to a version, this still create a new version
  def revert(version_id, user_id: nil)
    version = self.versions.find_by_id(version_id)
    if version.blank?
      errors.add(:base, "Revert version is invalid")
      return false
    end

    self.update(body: version.body_plain, last_editor_id: user_id)
  end

  private

    def track_doc_version_on_create
      self.versions.create!(user_id: self.last_editor_id, body: self.body)
    end

    def track_doc_version
      return unless self.body.changed?

      self.versions.create!(user_id: self.last_editor_id, body: self.body)
    end
end
