module Types
  class UserObject < BaseObject
    graphql_name "User"
    field :slug, String, null: false
    field :name, String, null: false
  end
end