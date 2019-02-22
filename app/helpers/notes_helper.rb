# frozen_string_literal: true

module NotesHelper
  def note_title_tag(note)
    return "" if note.blank?
    return "" if note.user.blank?

    link_to truncate(note.title, length: 100), note.to_path, class: "note-link", title: note.title
  end
end
