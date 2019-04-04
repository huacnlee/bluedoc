# frozen_string_literal: true

module Types
  class DocsType < PaginationType
    field :records, [DocType], null: false, description: "Doc collection for current page"
  end
end
