# frozen_string_literal: true

module Types
  class Query
    field :search, SearchObject, null: true do
      argument :type, String, required: true, description: "Search type: [user,group,repository,doc]"
      argument :limit, Integer, required: false, description: "Result limit, default: 10"
      argument :query, String, required: true, description: "Search query"
      argument :repository_id, Integer, required: false, description: "For type: doc, search docs in a repository"
    end

    def search(params)
      params[:limit] ||= 10
      result = case params[:type]
               when "doc"
                 search_docs(params)
               when "user"
                 search_users(params)
               end

      result[:limit] = params[:limit]
      result
    end

    def search_docs(params)
      search_options = { include_private: false }
      if params[:repository_id]
        repository = Repository.find(params[:repository_id])
        authorize! :read, repository

        search_options = { repository_id: repository.id, include_private: true }
      end

      result = BlueDoc::Search.new(:docs, params[:query], search_options).execute.limit(params[:limit])
      @docs = []
      result.records.each_with_hit do |item, hit|
        @docs << item
      end
      { total: result.total_count, records: @docs }
    end

    def search_users(params)
      result = BlueDoc::Search.new(:users, params[:query]).execute.limit(params[:limit])
      @users = []
      result.records.each_with_hit do |item, hit|
        @users << item
      end
      { total: result.total_count, records: @users }
    end
  end
end
