# frozen_string_literal: true

class RepositoriesController < Users::ApplicationController
  before_action :authenticate_anonymous!
  before_action :authenticate_user!, only: %i[new import edit create update destroy action]

  before_action :set_user, only: %i[show edit update destroy docs search action]
  before_action :set_repository, only: %i[show edit update destroy docs search action]

  def index
    authorize! :read, @user
  end

  # /new
  def new
    @repository = Repository.new(user_id: params[:user_id] || current_user.id)
  end

  # /new/import
  def import
    @repository = Repository.new(user_id: params[:user_id] || current_user.id)
    params[:_by] = "import"
    render :new
  end

  # POST /repositories
  def create
    repository_params[:slug].strip!
    @repository = Repository.new(repository_params)

    authorize! :create, @repository

    respond_to do |format|
      if @repository.save
        @repository.import_from_source
        Activities::Repository.new(@repository).create

        notice = t(".Repository was successfully created")
        if @repository.source?
          notice = t(".Repository was successfully created, and executed importing in background")
        end

        format.html { redirect_to @repository.to_path, notice: notice }
        format.json { render :show, status: :created, location: @repository }
      else
        format.html { render :new }
        format.json { render json: @repository.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /:user/:repo
  def show
    authorize! :read, @repository

    if @repository.has_toc?
      @tocs = graphql_query(:repositoryTocs, "repositoryId: #{@repository.id}", "id, docId, title, url, parentId, depth")
    else
      docs
      render "docs"
    end
  end

  # GET /:user/:repo/docs/list
  def docs
    authorize! :read, @repository
  end

  # GET /:user/:repo/docs/search
  def search
    if params[:q].blank?
      return redirect_to docs_user_repository_path(@user, @repository)
    end

    authorize! :read, @repository

    @result = BlueDoc::Search.new(:docs, params[:q], repository_id: @repository.id, include_private: true).execute.page(params[:page])
  end

  def action
    authorize! :read, @repository

    if request.post?
      User.create_action(params[:action_type], target: @repository, user: current_user)

      if params[:action_type] == "star"
        Activities::Repository.new(@repository).star
      end
    else
      User.destroy_action(params[:action_type], target: @repository, user: current_user)
    end
    @repository.reload
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_repository
    @repository = @user.owned_repositories.find_by_slug!(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def repository_params
    params.require(:repository).permit(:user_id, :slug, :name, :description, :privacy, :gitbook_url, :import_archive)
  end
end
