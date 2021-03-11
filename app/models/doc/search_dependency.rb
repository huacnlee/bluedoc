# frozen_string_literal: true

class Doc
  include Searchable

  def as_indexed_json(_options = {})
    {
      slug: slug,
      title: title,
      body: body_plain,
      search_body: _search_body,
      repository_id: repository_id,
      user_id: repository.user_id,
      repository: {
        public: repository.public?
      },
      deleted: deleted?
    }
  end

  def indexed_changed?
    saved_change_to_deleted_at? ||
      saved_change_to_title? ||
      body.changed?
  end

  def _search_body
    [repository&.user&.fullname, repository&.fullname, to_path, body_plain].join("\n\n")
  end
end
