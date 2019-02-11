module Types
  class DocObject < BaseObject
    graphql_name "Doc"

    field :slug, String, null: false
    field :title, String, null: false
  end
end