# frozen_string_literal: true

# PRO-begin
class DocsController
  # POST /:user/:repo/:slug/pdf
  def pdf
    set_doc
    authenticate_user!
    check_feature! :export_pdf

    authorize! :update, @doc

    if params[:force]
      @doc.export(:pdf)
    end
  end
end
# PRO-end
