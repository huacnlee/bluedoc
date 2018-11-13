# frozen_string_literal: true

class RepositoriesController < Users::ApplicationController
  before_action :authenticate_user!, only: %i[new edit create update destroy action toc]

  before_action :set_user, only: %i(show edit update destroy docs search action toc)
  before_action :set_repository, only: %i(show edit update destroy docs search action toc)

  def index
    authorize! :read, @user
  end

  #
  def new
    @repository = Repository.new
  end

  # POST /repositories
  def create
    @repository = Repository.new(repository_params)

    authorize! :create, @repository

    respond_to do |format|
      if @repository.save
        Activities::Repository.new(@repository).create

        notice = "Repository was successfully created."
        if repository_params[:gitbook_url]
          RepositoryImportJob.perform_later(@repository, type: "gitbook", user: current_user, url: repository_params[:gitbook_url])
          notice = "Repository as created, and runing import GitBook on background."
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

    unless @repository.has_toc?
      docs
      render "docs"
    end
  end

  # GET /:user/:repo/docs/list
  def docs
    authorize! :read, @repository

    @docs = @repository.docs.includes(:last_editor).recent.page(params[:page]).per(50)
  end

  # GET /:user/:repo/docs/search
  def search
    if params[:q].blank?
      return redirect_to docs_user_repository_path(@user, @repository)
    end

    authorize! :read, @repository

    @result = BookLab::Search.new(:docs, params[:q], repository_id: @repository.id, include_private: true).execute.page(params[:page])
  end

  # GET /:user/:repo/toc/edit
  def toc
    authorize! :create_doc, @repository

    if request.get?
      @docs = @repository.docs.order("id desc")
    else
      if @repository.update(params.require(:repository).permit(:toc))
        redirect_to @repository.to_path, notice: "Table of Contents has updated"
      else
        render :toc
      end
    end
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
      @repository = @user.repositories.find_by_slug!(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def repository_params
      params.require(:repository).permit(:user_id, :slug, :name, :description, :privacy, :gitbook_url)
    end
end
