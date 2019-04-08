# frozen_string_literal: true

module Queries
  class QueryType < BaseQuery
    field :doc, Types::DocType, null: true, description: "Get Doc by id" do
      argument :id, Integer, required: true
    end

    def doc(id:)
      @doc = Doc.find(id)
      authorize! :read, @doc

      @doc
    end

    field :repository_tocs, [Types::RepositoryTocType], null: true, description: "Get all toc list for Repository (Ordered with toc order)" do
      argument :repository_id, ID, required: true
    end
    def repository_tocs(params)
      @repository = Repository.find(params[:repository_id])
      authorize! :read, @repository

      @repository.tocs.nested_tree.includes(:doc)
    end

    # Get docs in a repository
    field :repository_docs, Types::DocsType, null: true, description: "Get doc list by pagination" do
      argument :repository_id, ID, required: true
      argument :page, Integer, required: false, default_value: 1
      argument :per, Integer, required: false, default_value: 20
      argument :sort, String, required: false, default_value: "created"
    end
    def repository_docs(params)
      params[:sort] ||= "created"

      @repository = Repository.find(params[:repository_id])
      authorize! :read, @repository

      @docs = @repository.docs.includes(:last_editor, :share)

      if params[:sort] == "created"
        @docs = @docs.order("id asc")
      else
        @docs = @docs.recent
      end

      @docs.page(params[:page]).per(params[:per])
    end
  end
end
