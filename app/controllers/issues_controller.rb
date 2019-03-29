class IssuesController < Users::ApplicationController
  before_action :authenticate_anonymous!
  before_action :authenticate_user!, only: %i[new create assignees labels edit update]
  before_action :set_user
  before_action :set_repository
  before_action :set_issue, only: %i[show edit update assignees labels]

  def index
    authorize! :read, @repository

    @repository.ensure_default_issue_labels

    @issues = @repository.issues.includes(:user, :last_editor)
    if params[:status] == "closed"
      @issues = @issues.closed
    else
      @issues = @issues.open
    end

    if !params[:label_id].blank?
      @issues = @issues.with_labels(params[:label_id])
    end

    if !params[:assignee_id].blank?
      @issues = @issues.with_assignees(params[:assignee_id])
    end

    @issues = @issues.order("iid desc").page(params[:page]).per(12)
    @issues = @issues.preload_assignees.preload_labels
    render :index
  end

  def closed
    params[:status] = "closed"
    index
  end

  def new
    authorize! :create_issue, @repository

    @issue = @repository.issues.new
  end

  def create
    authorize! :create_issue, @repository

    @issue = @repository.issues.new(issue_params)
    @issue.user_id = current_user.id
    if @issue.save
      redirect_to @issue.to_path, notice: t(".Issue was successfully created")
    else
      render :new
    end
  end

  def show
    authorize! :read, @issue

    @comments = @issue.comments.with_includes.order("id asc")
  end

  def edit
    authorize! :update, @issue
  end

  def update
    authorize! :update, @issue

    update_params = issue_params.to_hash.deep_symbolize_keys
    update_params[:last_editor_id] = current_user.id
    update_params[:last_edited_at] = Time.now
    if @issue.update(update_params)
      redirect_to @issue.to_path, notice: t(".Issue was successfully updated")
    else
      render :edit
    end
  end

  def assignees
    authorize! :manage, @issue

    if params[:clear]
      @issue.update_assignees([])
    else
      unless issue_params[:assignee_id].nil?
        @issue.update_assignees(issue_params[:assignee_id])
      end
    end

    render json: { ok: true, assignees: @issue.assignees.collect(&:as_item_json) }
  end

  def labels
    authorize! :manage, @issue

    if params[:clear]
      @issue.update_labels([])
    else
      unless issue_params[:label_id].nil?
        @issue.update_labels(issue_params[:label_id])
      end
    end

    render json: { ok: true, labels: @issue.labels.as_json }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_repository
      @repository = @user.owned_repositories.find_by_slug!(params[:repository_id])

      raise ActiveRecord::RecordNotFound unless @repository.has_issues?
    end

    def set_issue
      @issue = @repository.issues.find_by_iid!(params[:id])
    end

    def issue_params
      params.require(:issue).permit(:title, :body, :body_sml, :format, :status, assignee_id: [], label_id: [])
    end
end