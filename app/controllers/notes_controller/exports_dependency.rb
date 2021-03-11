# frozen_string_literal: true

class NotesController
  # POST /:user/notes/:slug/pdf
  def pdf
    set_note

    authenticate_user!

    authorize! :update, @note

    if params[:force]
      @note.export(:pdf)
    end

    # Let note same as a Doc to use doc view
    @doc = @note
    render "/docs/pdf"
  end
end
