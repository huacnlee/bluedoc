module Types
  class Query
    field :search, SearchObject, null: true do
      argument :type, String, required: true
      argument :limit, Integer, required: false
      argument :query, String, required: true
      argument :repository_id, Integer, required: false
    end

    def search(params)
      params[:limit] ||= 10
      case params[:type]
      when "doc"
        search_docs(params)
      end
    end

    def search_docs(params)
      repository = Repository.find(params[:repository_id])
      result = BookLab::Search.new(:docs, params[:query], repository_id: repository.id, include_private: true).execute.limit(params[:limit])
      @docs = []
      result.records.each_with_hit do |item, hit|
        @docs << item
      end
      { total: result.total_count, nodes: @docs }
    end
  end
end