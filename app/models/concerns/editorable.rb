module Editorable
  def editors
    users = Rails.cache.fetch([self.cache_key, "editors/without-avatar", self.editor_ids]) do
      users = User.where(id: self.editor_ids)
      users.sort { |a, b| self.editor_ids.index(a.id) <=> self.editor_ids.index(b.id) }
    end
  end

  def add_editor(editor_id)
    return if editor_id.blank?

    if editor_id.is_a?(Array)
      self.editor_ids += editor_id
    else
      self.editor_ids << editor_id
    end

    self.editor_ids.compact!
    self.editor_ids.uniq!
  end
end