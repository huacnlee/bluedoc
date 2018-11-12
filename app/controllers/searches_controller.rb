class SearchesController < ApplicationController
  before_action :set_totals, except: [:index]

  def index
    redirect_to docs_search_path(q: params[:q])
  end

  def docs
    @result = BookLab::Search.new(:docs, params[:q]).execute.page(params[:page])
  end

  def repositories
    @result = BookLab::Search.new(:repositories, params[:q]).execute.page(params[:page])
  end

  def groups
    @result = BookLab::Search.new(:groups, params[:q]).execute.page(params[:page])
  end

  def users
    @result = BookLab::Search.new(:users, params[:q]).execute.page(params[:page])
  end

  private
    def set_totals
      @totals = {
        docs: BookLab::Search.new(:docs, params[:q]).execute.count,
        repositories: BookLab::Search.new(:repositories, params[:q]).execute.count,
        groups: BookLab::Search.new(:groups, params[:q]).execute.count,
        users: BookLab::Search.new(:users, params[:q]).execute.count,
      }
    end
end