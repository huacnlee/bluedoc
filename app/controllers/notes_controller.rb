# frozen_string_literal: true

class NotesController < Users::ApplicationController
  before_action :authenticate_anonymous!

  before_action :set_user
  before_action :set_note, only: %i[edit update destroy versions revert raw]
  before_action :authenticate_user!, only: %i[new edit update destroy versions revert]

  def index
    @notes = @user.notes.recent.page(params[:page])
  end

  def new
    @note = Note.create_new(current_user.id, slug: params[:slug])
    redirect_to @note.to_path("/edit")
  end

  def show
    authorize! :read, @note
  end

  def edit
    authorize! :update, @note

    render :edit, layout: "editor"
  end

  def update
    authorize! :update, @note

    if @note.update(note_params)
      redirect_to @note.to_path, notice: "Note was successfully updated."
    else
      render :edit, layout: "editor"
    end
  end

  def destroy
    authorize! :destroy, @note

    @note.destroy
    redirect_to @user.to_path("/notes"), notice: "Note was successfully deleted."
  end

  # GET /:user/notes/:slug/raw
  def raw
    authorize! :read, @note

    render plain: @note.body_plain
  end

  private

    def set_note
      @note = @user.notes.find_by_slug(params[:id])
    end

    def note_params
      params.require(:note).permit(:title, :body, :body_sml, :slug, :format)
    end
end