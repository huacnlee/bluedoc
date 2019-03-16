# frozen_string_literal: true

class RepositorySettingsController < Users::ApplicationController
  # PRO-begin
  depends_on :exports
  # PRO-end

  before_action :authenticate_anonymous!
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
      redirect_to user_repository_settings_path(@user, @repository), notice: t(".Repository was successfully updated")
    else
      # FIXME: Render path contains parameter value issue
      render action: params[:_action]
    end
  end

  def transfer
    authorize! :update, @repository

    new_slug = params.require(:repository).permit(:transfer_to_user)[:transfer_to_user]

    if @repository.transfer(new_slug)
      @repository.reload
      redirect_to @repository.to_path, notice: t(".Repository was successfully transfered")
    else
      redirect_to advanced_user_repository_settings_path(@user, @repository), alert: @repository.errors[:user_id].join("")
    end
  end

  def destroy
    authorize! :destroy, @repository

    @repository.destroy
    redirect_to @user.to_path, notice: t(".Repository has successfully destroyed")
  end

  def docs
    authorize! :update, @repository

    @docs = @repository.docs.order("id desc")

    if request.post?
      transfer_params = params.require(:transfer).permit(:repository_id, doc_id: [])

      @target_repository = Repository.find(transfer_params[:repository_id])
      authorize! :update, @target_repository

      transfer_docs = @docs.where(id: transfer_params[:doc_id])
      Doc.transfer_docs(transfer_docs, @target_repository)

      notice = t(".Successfully transfered docs to",
        num: transfer_docs.length,
        path: "#{@target_repository.user&.name} / #{@target_repository.name}"
      )
      redirect_to docs_user_repository_settings_path(@user, @repository), notice: notice
    end
  end

  # GET /:user/:repo/settings/collaborators
  def collaborators
    authorize! :update, @repository

    if request.post?
      member_params = params.require(:member).permit(:user_slug)

      user = User.find_by_slug!(member_params[:user_slug])

      # Avoid change self
      if user.id == current_user.id
        raise ActiveRecord::RecordNotFound
      end

      @member = @repository.add_member(user, :editor)
    else
      @members = @repository.members.includes(user: { avatar_attachment: :blob }).order("id asc").page(params[:page]).per(20)
    end
  end

  # POST/DELETE /:user/:repo/settings/collaborator
  def collaborator
    authorize! :update, @repository

    member_params = params.require(:member).permit(:id, :role)

    @member = @repository.members.find(member_params[:id])
    if @member.user_id == current_user.id
      raise CanCan::AccessDenied
    end

    if request.delete?
      @member.destroy
    else
      @member.update(role: member_params[:role])
    end
  end

  # POST /:user/:repo/settings/retry_import
  def retry_import
    authorize! :update, @repository

    if params[:abort]
      @repository.source.destroy
      redirect_to @repository.to_path
    else
      @repository.import_from_source
      redirect_to @repository.to_path, notice: t(".Repository import has started")
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_repository
      @repository = @user.owned_repositories.find_by_slug!(params[:repository_id])
    end

    def repository_params
      params.require(:repository).permit(:name, :slug, :description, :privacy, :has_toc)
    end
end
