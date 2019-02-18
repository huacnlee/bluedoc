# frozen_string_literal: true

class NotesController < Users::ApplicationController
  before_action :authenticate_anonymous!

  before_action :set_user, except: %i[new create]
  before_action :set_note, only: %i[show edit update destroy versions revert raw]
  before_action :authenticate_user!, only: %i[new edit update destroy versions revert]

  def index
    @notes = @user.notes.recent
    if @user != current_user
      @notes = @notes.publics
    end
    @notes = @notes.page(params[:page])
  end

  def new
    @note = Note.create_new(current_user.id, slug: params[:slug])
    redirect_to @note.to_path("/edit")
  rescue ActiveRecord::RecordInvalid => e
    redirect_to current_user.to_path("/notes/#{params[:slug]}"), alert: "Create slug as #{params[:slug]} failed, maybe it exist."
  end

  def show
    authorize! :read, @note

    @comments = @note.comments.with_includes.order("id asc")
    @between_notes = @note.prev_and_next_of_notes

    render :show, layout: "reader"
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

  # GET /:user/:repo/:slug/versions
  def versions
    authorize! :update, @note

    @current_version = @note.versions.includes(:user).first
    @previous_version = @note.versions.second
    @versions = @note.versions.where("id <> ?", @current_version.id).includes(:user).page(params[:page]).per(7)
    render "versions", layout: "reader"
  end

  # POST /:user/:repo/:slug/revert
  def revert
    authorize! :update, @note

    version_id = params.permit(:version_id)[:version_id]
    if @note.revert(version_id, user_id: current_user.id)
      redirect_to @note.to_path, notice: "Note was successfully reverted."
    else
      redirect_to @note.to_path("/versions"), alert: "Revert failed, please check a exists version."
    end
  end

  private

    def set_note
      @note = @user.notes.find_by_slug(params[:id])
    end

    def note_params
      params.require(:note).permit(:title, :body, :body_sml, :slug, :format)
    end
end