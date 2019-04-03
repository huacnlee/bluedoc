module Types
  # Kaminari style pagination result
  class PageInfoType < GraphQL::Schema::Object
    field :total_count, Integer, null: false, description: "Total count"
    field :total_pages, Integer, null: false, description: "Total pages"

    field :page, Integer, null: false, description: "Current page number"
    def page
      object.current_page
    end

    field :per, Integer, null: false, description: "Per page size"
    def per
      object.current_per_page
    end

    field :next_page, Integer, null: true, description: "Next page number"
    field :prev_page, Integer, null: true, description: "Prev page number"

    field :first_page, Boolean, null: false, description: "First page of the collection?"
    def first_page
      object.first_page?
    end

    field :last_page, Boolean, null: false, description: "Last page of the collection?"
    def last_page
      object.last_page?
    end
  end
end
