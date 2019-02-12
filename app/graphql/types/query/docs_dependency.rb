module Types
  class Query
    field :doc_by_id, DocObject, null: true do
      argument :id, Integer, required: true
    end

    def doc_by_id(id:)
      Doc.find(id)
    end
  end
end