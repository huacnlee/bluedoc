module Types
  class PaginationType < GraphQL::Schema::Object
    field :page_info, PageInfoType, null: false
    def page_info
      object
    end
  end
end
