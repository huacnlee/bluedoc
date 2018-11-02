class RepositorySettingsController < Users::ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_repository

  def show
    authorize! :update, @repository
  end

  def advanced
    authorize! :update, @repository
  end

  def update
    authorize! :update, @repository

    if @repository.update(repository_params)
      redirect_to user_repository_settings_path(@user, @repository), notice: "Update successed"
    else
      render params[:action]
    end
  end

  def destroy
    authorize! :destroy, @repository

    @repository.destroy
    redirect_to @user.to_path, notice: "Repository has destroyed"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_repository
      @repository = @user.repositories.find_by_slug!(params[:repository_id])
    end

    def repository_params
      params.require(:repository).permit(:name, :slug, :description, :privacy, :has_toc)
    end
end
