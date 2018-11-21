# frozen_string_literal: true

class Admin::RepositoriesController < Admin::ApplicationController
  before_action :set_repository, only: [:show, :edit, :update, :destroy]

  def index
    @repositories = Repository.includes(:user).order("id desc")
    if params[:q]
      q = "%#{params[:q]}%"
      @repositories = @repositories.where("name ilike ? or slug = ? or description ilike ?", q, q, q)
    end
    if params[:user_id]
      @repositories = @repositories.where(user_id: params[:user_id])
    end
    @repositories = @repositories.page(params[:page])
  end

  def show
  end

  def new
    @repository = Repository.new
  end

  def edit
  end

  def create
    @repository = Repository.new(repository_params)

    if @repository.save
      redirect_to(admin_repositories_path, notice: "Repository was successfully created.")
    else
      render :new
    end
  end

  def update
    if @repository.update(repository_params)
      redirect_to admin_repositories_path, notice: "Repository was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @repository.destroy
    redirect_to admin_repositories_path, notice: "Repository was successfully deleted."
  end

  private

    def set_repository
      @repository = Repository.find(params[:id])
    end

    def repository_params
      params.require(:repository).permit!
    end
end
