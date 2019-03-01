class NotesController
  # GET /:user/notes/:slug/readers
  def readers
    check_feature! :reader_list

    authorize! :read, @note
    @readers = @note.read_by_user_actions.order("updated_at desc").all
  end
end