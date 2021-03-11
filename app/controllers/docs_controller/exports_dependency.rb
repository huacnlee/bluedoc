# frozen_string_literal: true

class DocsController
  # POST /:user/:repo/:slug/pdf
  def pdf
    set_doc
    authenticate_user!

    authorize! :update, @doc

    if params[:force]
      @doc.export(:pdf)
    end
  end
end
