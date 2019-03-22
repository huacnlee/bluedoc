class IssuesController < Users::ApplicationController
  before_action :authenticate_anonymous!
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_repository
  before_action :set_issue, only: %i[show assignees]

  def index
    @issues = @repository.issues.includes(:user, :last_editor).open.order("iid desc").page(params[:page]).per(20)
  end

  def new
    @issue = @repository.issues.new
  end

  def create
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

  def assignees
    authorize! :update, @issue

    if params[:clear]
      @issue.update_assignees([])
    else
      unless issue_params[:assignee_id].nil?
        @issue.update_assignees(issue_params[:assignee_id])
      end
    end

    render json: { ok: true, assignees: @issue.assignees.collect(&:as_item_json) }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_repository
      @repository = @user.owned_repositories.find_by_slug!(params[:repository_id])
    end

    def set_issue
      @issue = @repository.issues.find_by_iid!(params[:id])
    end

    def issue_params
      params.require(:issue).permit(:title, :body, :body_sml, :format, assignee_id: [])
    end
end