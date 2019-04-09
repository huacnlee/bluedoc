# frozen_string_literal: true

class SearchesController < ApplicationController
  before_action :authenticate_anonymous!
  before_action :set_totals, except: [:index]

  def show
    redirect_to docs_search_path(q: params[:q])
  end

  def docs
    set_nav_search url: docs_search_path
    @result = BlueDoc::Search.new(:docs, params[:q]).execute.page(params[:page])
  end

  def notes
    set_nav_search url: notes_search_path
    @result = BlueDoc::Search.new(:notes, params[:q]).execute.page(params[:page])
  end

  def repositories
    set_nav_search url: repositories_search_path
    @result = BlueDoc::Search.new(:repositories, params[:q]).execute.page(params[:page])
  end

  def groups
    set_nav_search url: groups_search_path
    @result = BlueDoc::Search.new(:groups, params[:q]).execute.page(params[:page])
  end

  def users
    set_nav_search url: users_search_path
    @result = BlueDoc::Search.new(:users, params[:q]).execute.page(params[:page])
  end

  def issues
    set_nav_search url: issues_search_path
    @result = BlueDoc::Search.new(:issues, params[:q]).execute.page(params[:page])
  end

  private
    def set_totals
      @totals = {
        docs: BlueDoc::Search.new(:docs, params[:q]).execute.count,
        notes: BlueDoc::Search.new(:notes, params[:q]).execute.count,
        repositories: BlueDoc::Search.new(:repositories, params[:q]).execute.count,
        groups: BlueDoc::Search.new(:groups, params[:q]).execute.count,
        users: BlueDoc::Search.new(:users, params[:q]).execute.count,
        issues: BlueDoc::Search.new(:issues, params[:q]).execute.count,
      }
    end
end
