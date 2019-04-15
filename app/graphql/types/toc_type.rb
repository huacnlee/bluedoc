# frozen_string_literal: true

module Types
  class TocType < BaseType
    graphql_name "Toc"
    description "Toc item for Doc for describe the doc in the table of contents tree"

    field :parent_id, Integer, null: true, description: "Parent toc id"
    field :depth, Integer, null: false, description: "Depth"
    field :title, String, null: true
    field :url, String, null: true
    field :doc_id, Integer, null: true, description: "Relative doc id"
  end
end
