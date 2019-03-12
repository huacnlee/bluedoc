# frozen_string_literal: true

class DocsController < Users::ApplicationController
  # PRO-begin
  depends_on :readers, :exports
  # PRO-end

  before_action :authenticate_anonymous!
  before_action :authenticate_user!, only: %i[new edit create update destroy versions revert action lock share]

  before_action :set_user
  before_action :set_repository
  before_action :set_doc, except: %i[index new create]

  # GET /:user/:repo/:slug
  def show
    if @doc.blank?
      authorize! :read, @repository
    else
      authorize! :read, @doc

      # mark user to read this doc
      current_user&.read_doc(@doc)
      @readers = @doc.read_by_user_actions.order("updated_at desc").limit(5)

      @comments = @doc.comments.with_includes.order("id asc")

      # mark notifications read
      Notification.read_targets(current_user, target_type: "Comment", target_id: @comments.collect(&:id))

      @reactions = @doc.reactions

      @between_docs = @doc.prev_and_next_of_docs
    end

    render "show", layout: "reader"
  end

  # GET /:user/:repo/docs/new
  def new
    authorize! :create_doc, @repository

    @doc = Doc.create_new(@repository, current_user.id, slug: params[:slug])
    redirect_to @doc.to_path("/edit")
  rescue ActiveRecord::RecordInvalid => e
    redirect_to @repository.to_path("/#{params[:slug]}"), alert: "Create slug as #{params[:slug]} failed, maybe it exist."
  end

  # GET /:user/:repo/:slug/edit
  def edit
    authorize! :update, @doc

    render :edit, layout: "editor"
  end

  # PATCH/PUT /:user/:repo/:slug
  def update
    authorize! :update, @doc

    update_params = doc_params.to_hash.deep_symbolize_keys
    update_params[:last_editor_id] = current_user.id
    update_params[:current_editor_id] = current_user.id
    update_params[:draft_title] = update_params[:title] if update_params[:title].present?
    update_params[:draft_body] = update_params[:body] if update_params[:body].present?
    update_params[:draft_body_sml] = update_params[:body_sml] if update_params[:body_sml].present?

    # Mark as publishing on Publish doc
    if update_params[:body_sml].present?
      @doc.publishing!
    end

    # avoid change format on draft save
    if update_params[:body_sml].blank?
      update_params[:format] = @doc.format
    end

    respond_to do |format|
      if @doc.update(update_params)
        format.html {
          @doc.unlock!
          redirect_to @doc.to_path, notice: t(".Doc was successfully updated")
        }
        format.json { render json: { ok: true, doc: { slug: @doc.slug } } }
      else
        format.html { render :edit, layout: "editor" }
        format.json { render json: { ok: false, messages: @doc.errors.full_messages } }
      end
    end
  end

  # GET /:user/:repo/:slug/raw
  def raw
    authorize! :read, @doc

    respond_to do |format|
      format.html { render :raw, layout: "editor" }
      format.text { render plain: @doc.body_plain }
    end
  end

  # GET /:user/:repo/:slug/versions
  def versions
    authorize! :update, @doc

    @current_version = @doc.versions.includes(:user).first
    @previous_version = @doc.versions.second
    @versions = @doc.versions.where("id <> ?", @current_version.id).includes(:user).page(params[:page]).per(7)
    render "versions", layout: "reader"
  end

  # POST /:user/:repo/:slug/revert
  def revert
    authorize! :update, @doc

    version_id = params.permit(:version_id)[:version_id]
    if @doc.revert(version_id, user_id: current_user.id)
      redirect_to @doc.to_path, notice: t(".Doc was successfully reverted")
    else
      redirect_to @doc.to_path("/versions"), alert: t(".Revert failed, please check a exists version")
    end
  end

  # POST /:user/:repo/:slug/action
  # DELETE /:user/:repo/:slug/action
  def action
    authorize! :read, @doc

    if request.post?
      User.create_action(params[:action_type], target: @doc, user: current_user)

      if params[:action_type] == "star"
        Activities::Doc.new(@doc).star
      end
    else
      User.destroy_action(params[:action_type], target: @doc, user: current_user)
    end
    @doc.reload
  end

  # DELETE /:user/:repo/:slug
  def destroy
    authorize! :destroy, @doc

    @doc.destroy
    respond_to do |format|
      format.html { redirect_to @repository.to_path, notice: t(".Doc was successfully destroyed") }
      format.json { head :no_content }
      format.js
    end
  end

  # POST /:user/:repo/:slug/lock
  def lock
    authorize! :update, @doc

    if params[:unlock]
      @doc.unlock!
    else
      @doc.lock!(current_user)
    end

    respond_to do |format|
      format.json do
        render json: { ok: true }
      end
      format.js
    end
  end

  # POST /:user/:repo/:slug/share
  def share
    authorize! :update, @doc

    if params[:unshare]
      @doc.share&.destroy
      @doc.reload
    else
      Share.create_share(@doc, user: current_user)
    end
  end

  private
    def set_repository
      @repository = @user.owned_repositories.find_by_slug!(params[:repository_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_doc
      @doc = @repository.docs.find_by_slug(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def doc_params
      params.require(:doc).permit(:title, :draft_title, :body, :body_sml, :draft_body, :draft_body_sml, :slug, :format)
    end
end
