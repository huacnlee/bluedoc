class IssuesController < Users::ApplicationController
  before_action :authenticate_anonymous!
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_repository
  before_action :set_issue, only: %i[show]

  def index
    @issues = @repository.issues.open.order("updated_at desc").page(params[:page]).per(20)
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
    @comments = @issue.comments.with_includes.order("id asc")
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
      params.require(:issue).permit(:title, :body, :body_sml, :format)
    end
end