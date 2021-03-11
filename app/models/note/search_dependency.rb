# frozen_string_literal: true

class Note
  include Searchable

  def as_indexed_json(_options = {})
    {
      slug: slug,
      title: title,
      body: body_plain,
      search_body: _search_body,
      user_id: user_id,
      public: public?,
      deleted: deleted?
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
    [user&.fullname, to_path, body_plain].join("\n\n")
  end
end
