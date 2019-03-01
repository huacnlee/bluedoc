# frozen_string_literal: true

class NotesController < Users::ApplicationController
  # PRO-start
  depends_on :readers, :exports
  # PRO-end

  before_action :authenticate_anonymous!

  before_action :set_user, except: %i[new create]
  before_action :set_note, only: %i[show edit update destroy versions revert raw action]
  before_action :authenticate_user!, except: %i[index show readers raw]

  def index
    @notes = @user.notes.recent
    if @user != current_user
      @notes = @notes.publics
    end
    @notes = @notes.page(params[:page])
  end

  def new
    @user = current_user
    @note = Note.new(slug: params[:slug] || BlueDoc::Slug.random)
  end

  def create
    @user = current_user
    @note = @user.notes.new(note_params)
    @note.format = "sml"
    if @note.save
      redirect_to @note.to_path("/edit")
    else
      render "new"
    end
  end

  def show
    authorize! :read, @note

    @comments = @note.comments.with_includes.order("id asc")
    @between_notes = @note.prev_and_next_of_notes(with_user: current_user)
    @readers = @note.read_by_user_actions.order("updated_at desc").limit(5)

    if current_user
      current_user.read_note(@note)
    end

    render :show, layout: "reader"
  end

  def edit
    authorize! :update, @note

    render :edit, layout: "editor"
  end

  def update
    authorize! :update, @note

    if note_params[:body_sml].blank?
      note_params[:format] = @note.format
    end

    respond_to do |format|
      if @note.update(note_params)
        format.html { redirect_to @note.to_path, notice: t(".Note was successfully updated") }
        format.json { render json: { ok: true, note: { slug: @note.slug } } }
      else
        format.html { render :edit, layout: "editor" }
        format.json { render json: { ok: false, messages: @note.errors.full_messages } }
      end
    end
  end

  def destroy
    authorize! :destroy, @note

    @note.destroy
    redirect_to @user.to_path("/notes"), notice: t(".Note was successfully deleted")
  end

  # GET /:user/notes/:slug/raw
  def raw
    authorize! :read, @note

    respond_to do |format|
      format.html { render :raw, layout: "editor" }
      format.text { render plain: @note.body_plain }
    end
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
      redirect_to @note.to_path, notice: t(".Note was successfully reverted")
    else
      redirect_to @note.to_path("/versions"), alert: t(".Revert failed, please check a exists version")
    end
  end

  # POST /:user/notes/:slug/action
  # DELETE /:user/notes/:slug/action
  def action
    authorize! :read, @note

    if request.post?
      User.create_action(params[:action_type], target: @note, user: current_user)

      if params[:action_type] == "star"
        Activities::Note.new(@note).star
      end
    else
      User.destroy_action(params[:action_type], target: @note, user: current_user)
    end
    @note.reload
  end

  private

    def set_note
      @note = @user.notes.find_by_slug(params[:id])
      raise ActiveRecord::RecordNotFound if @note.blank?
    end

    def note_params
      params.require(:note).permit(:title, :body, :body_sml, :slug, :format, :privacy, :description)
    end
end
