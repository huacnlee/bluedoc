module Types
  class Query
    field :doc, DocObject, null: true do
      argument :id, Integer, required: true
    end

    def doc(id:)
      @doc = Doc.find(id)
      authorize! :read, @doc

      @doc
    end
  end
end