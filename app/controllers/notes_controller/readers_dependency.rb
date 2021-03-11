# frozen_string_literal: true

class NotesController
  # GET /:user/notes/:slug/readers
  def readers
    set_note

    authorize! :read, @note
    @readers = @note.read_by_user_actions.order("updated_at desc").limit(100)
  end
end
