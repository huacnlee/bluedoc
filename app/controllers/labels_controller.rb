# frozen_string_literal: true

class LabelsController < Users::ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_repository
  before_action :set_label, only: %i[show edit update destroy]

  def index
    authorize! :update, @repository

    @labels = @repository.issue_labels.order("id asc")

    render :index
  end

  def create
    authorize! :update, @repository

    @label = @repository.issue_labels.new(label_params)
    if @label.save
      render json: { ok: true }
    else
      render json: { ok: false, errors: @label.errors.full_messages.first }
    end
  end

  def update
    authorize! :update, @repository

    if @label.update(label_params)
      render json: { ok: true }
    else
      render json: { ok: false, errors: @label.errors.full_messages.first }
    end
  end

  def destroy
    authorize! :update, @repository

    if @label.destroy
      render json: { ok: true }
    else
      render json: { ok: false, errors: @label.errors.full_messages }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_repository
      @repository = @user.owned_repositories.find_by_slug!(params[:repository_id])

      raise ActiveRecord::RecordNotFound unless @repository.has_issues?
    end

    def set_label
      @label = @repository.issue_labels.find(params[:id])
    end

    def label_params
      params.require(:label).permit(:title, :color)
    end
end
