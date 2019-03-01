# frozen_string_literal: true

# PRO-begin
class DocsController
  # GET /:user/:repo/:slug/readers
  def readers
    set_doc
    check_feature! :reader_list

    authorize! :read, @doc
    @readers = @doc.read_by_user_actions.order("updated_at desc").all
  end
end
# PRO-end
