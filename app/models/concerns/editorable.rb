# frozen_string_literal: true

module Editorable
  def editors
    # TODO: Add cache, and make sure cache can work with avatar (when user changed it avatar)
    users = User.where(id: self.editor_ids)
    users.sort { |a, b| self.editor_ids.index(a.id) <=> self.editor_ids.index(b.id) }
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
