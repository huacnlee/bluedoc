# frozen_string_literal: true

class Repository
  include Searchable

  def as_indexed_json(_options = {})
    {
      slug: self.slug,
      title: self.name,
      body: self._search_body,
      repository_id: self.id,
      user_id: self.user_id,
      repository: {
        public: self.public?,
      }
    }
  end

  def indexed_changed?
    saved_change_to_privacy? ||
    saved_change_to_name? ||
    saved_change_to_description?
  end

  def _search_body
    [self.user&.fullname, self.description, self.toc&.body.to_s].join("\n\n")
  end
end
