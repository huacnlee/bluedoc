# frozen_string_literal: true

class Repository
  include Searchable

  def as_indexed_json(_options = {})
    {
      slug: self.slug,
      title: self.name,
      body: self.description,
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
end
