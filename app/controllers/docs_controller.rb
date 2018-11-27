# frozen_string_literal: true

class DocsController < Users::ApplicationController
  before_action :authenticate_anonymous!
  before_action :authenticate_user!, only: %i[new edit create update destroy versions revert action]

  before_action :set_user
  before_action :set_repository
  before_action :set_doc, except: %i[index new create]

  # GET /docs
  # GET /docs.json
  def index
    authorize! :read, @repository

    @docs = Doc.all
  end

  # GET /docs/1
  # GET /docs/1.json
  def show
    if @doc.blank?
      authorize! :read, @repository
    else
      authorize! :read, @doc
      @comments = @doc.comments.with_includes.order("id asc")

      # mark notifications read
      Notification.read_targets(current_user, target_type: "Comment", target_id: @comments.collect(&:id))

      @reactions = @doc.reactions

      if @reactions.blank?
      end
    end

    render "show", layout: "reader"
  end

  # GET /docs/new
  def new
    authorize! :create_doc, @repository

    @doc = Doc.create_new(@repository, current_user.id)

    redirect_to @doc.to_path("/edit")
  end

  # GET /docs/1/edit
  def edit
    authorize! :update, @doc
    render :new, layout: "editor"
  end

  # PATCH/PUT /docs/1
  # PATCH/PUT /docs/1.json
  def update
    authorize! :update, @doc
    @doc.last_editor_id = current_user.id

    update_params = doc_params.to_hash.deep_symbolize_keys
    update_params[:draft_title] ||= update_params[:title]
    update_params[:draft_body] ||= update_params[:body]
    update_params[:draft_body_sml] ||= update_params[:body_sml]

    respond_to do |format|
      if @doc.update(update_params)
        format.html { redirect_to @doc.to_path, notice: "Doc was successfully updated." }
        format.json { render json: { ok: true } }
      else
        format.html { render :edit, layout: "editor" }
        format.json { render json: { ok: false } }
      end
    end
  end

  def raw
    authorize! :read, @doc

    render plain: @doc.body_plain
  end

  def versions
    authorize! :update, @doc

    @current_version = @doc.versions.includes(:user).first
    @versions = @doc.versions.where("id <> ?", @current_version.id).includes(:user).page(params[:page]).per(7)
    render "versions", layout: "reader"
  end

  def revert
    authorize! :update, @doc

    version_id = params.permit(:version_id)[:version_id]
    if @doc.revert(version_id, user_id: current_user.id)
      redirect_to @doc.to_path, notice: "Doc was successfully reverted."
    else
      redirect_to @doc.to_path("/versions"), alert: "Revert failed, please check a exists version."
    end
  end

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

  # DELETE /docs/1
  # DELETE /docs/1.json
  def destroy
    authorize! :destroy, @doc

    @doc.destroy
    respond_to do |format|
      format.html { redirect_to @repository.to_path, notice: "Doc was successfully destroyed." }
      format.json { head :no_content }
      format.js
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
      params.require(:doc).permit(:title, :draft_title, :body, :body_sml, :draft_body, :draft_body_sml, :slug)
    end
end
