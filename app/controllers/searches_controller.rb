class SearchesController < ApplicationController
  def docs
    @search_texts = SearchText.search(:docs, params[:q]).with_pg_search_highlight
  end
end