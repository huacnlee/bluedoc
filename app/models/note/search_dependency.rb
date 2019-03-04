# frozen_string_literal: true

class Note
  include Searchable

  def as_indexed_json(_options = {})
    {
      slug: self.slug,
      title: self.title,
      body: self.body_plain,
      search_body: self._search_body,
      user_id: self.user_id,
      public: self.public?,
      deleted: self.deleted?
    }
  end

  def indexed_changed?
    saved_change_to_deleted_at? ||
    saved_change_to_title? ||
    saved_change_to_privacy? ||
    saved_change_to_user_id? ||
    body.changed?
  end

  def _search_body
    [self.user&.fullname, self.to_path, self.body_plain].join("\n\n")
  end
end
