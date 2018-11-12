# frozen_string_literal: true

class Doc
  include Searchable

  mapping do
    indexes :title, term_vector: :yes
    indexes :body, term_vector: :yes
  end

  def as_indexed_json(_options = {})
    {
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