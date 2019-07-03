# frozen_string_literal: true

class Admin::IssuesController < Admin::ApplicationController
  before_action :set_issue, only: [:show, :edit, :update, :destroy]

  def index
    @issues = Issue.includes(:user, :repository).order("id desc")
    if !params[:q].blank?
      @issues = @issues.where("title ilike ?", "%#{params[:q]}%")
    end
    @issues = @issues.page(params[:page])
  end

  def show
  end

  def update
    if @issue.update(issue_params)
      redirect_to admin_issues_path, notice: t(".Issue was successfully updated.")
    else
      render :edit
    end
  end

  def destroy
    @issue.destroy
    redirect_to admin_issues_path, notice: t(".Issue was successfully deleted.")
  end

  private
    def set_issue
      @issue = Issue.find(params[:id])
    end

    def issue_params
      params.require(:issue).permit!
    end
end
