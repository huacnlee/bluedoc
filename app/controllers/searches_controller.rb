class SearchesController < ApplicationController
  def index
    redirect_to docs_search_path(q: params[:q])
  end

  def docs
    @search_texts = SearchText.search(:docs, params[:q]).with_pg_search_highlight.page(params[:page]).per(10)
  end

  def repositories
    @search_texts = SearchText.search(:repositories, params[:q]).with_pg_search_highlight.page(params[:page]).per(10)
  end

  def groups
    @search_texts = SearchText.search(:groups, params[:q]).with_pg_search_highlight.page(params[:page]).per(10)
  end
end