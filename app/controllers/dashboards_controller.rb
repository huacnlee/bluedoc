# frozen_string_literal: true

class DashboardsController < ApplicationController
  before_action :authenticate_anonymous!
  before_action :authenticate_user!

  def index
    @groups = current_user.groups.with_attached_avatar.limit(100)
    @recent_docs = current_user.user_actives.docs.limit(6)
    @recent_repos = current_user.user_actives.repositories.limit(12)
    @recent_issues = current_user.user_actives.issues.limit(12)

    @watched_repositories = current_user.watch_repositories.order("updated_at desc").includes(:user).page(params[:page]).per(12)
    @doc_groups = {}
    @watched_repositories.each do |repo|
      @doc_groups[repo.id] = repo.docs.order("body_updated_at desc").limit(5)
    end
  end

  def activities
    @activities = current_user.activities.includes(:actor, :target).page(params[:page]).per(20)
  end

  def show
    redirect_to root_path
  end

  def groups
    @groups = current_user.groups.with_attached_avatar.page(params[:page]).per(12)
  end

  def repositories
    @repositories = current_user.user_actives.repositories.includes(:user).page(params[:page]).per(12)
  end

  def docs
    @docs = current_user.user_actives.docs.page(params[:page]).per(6)
  end

  # GET /dashboard/stars?tab=
  def stars
    case params[:tab]
    when "docs"
      @docs = current_user.star_docs.includes(repository: :user).page(params[:page]).per(12)
    when "notes"
      @notes = current_user.star_notes.includes(:user).page(params[:page]).per(12)
    else
      @repositories = current_user.star_repositories.includes(:user).page(params[:page]).per(12)
    end
  end

end
