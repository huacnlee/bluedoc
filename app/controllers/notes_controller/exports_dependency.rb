# frozen_string_literal: true

# PRO-begin
class NotesController
  # POST /:user/notes/:slug/pdf
  def pdf
    set_note

    authenticate_user!
    check_feature! :export_pdf

    authorize! :update, @note

    if params[:force]
      @note.export(:pdf)
    end

    # Let note same as a Doc to use doc view
    @doc = @note
    render "/docs/pdf"
  end
end
# PRO-end
