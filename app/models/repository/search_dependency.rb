# frozen_string_literal: true

class Repository
  include Searchable

  def as_indexed_json(_options = {})
    {
      slug: slug,
      title: name,
      body: description,
      search_body: _search_body,
      repository_id: id,
      user_id: user_id,
      repository: {
        public: public?
      },
      deleted: deleted?
    }
  end

  def indexed_changed?
    saved_change_to_deleted_at? ||
      saved_change_to_privacy? ||
      saved_change_to_name? ||
      saved_change_to_description?
  end

  def _search_body
    [user&.fullname, description].join("\n\n")
  end
end
