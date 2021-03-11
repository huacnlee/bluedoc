# frozen_string_literal: true

class DocsController
  # GET /:user/:repo/:slug/readers
  def readers
    set_doc

    authorize! :read, @doc
    @readers = @doc.read_by_user_actions.order("updated_at desc").limit(100)
  end
end
