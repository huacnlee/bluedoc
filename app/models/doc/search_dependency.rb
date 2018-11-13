# frozen_string_literal: true

class Doc
  include Searchable

  def as_indexed_json(_options = {})
    {
      slug: self.slug,
      title: self.title,
      body: self.body_plain,
      repository_id: self.repository_id,
      user_id: self.repository.user_id,
      repository: {
        public: self.repository.public?,
      }
    }
  end

  def indexed_changed?
    saved_change_to_title? || body.changed?
  end
end
