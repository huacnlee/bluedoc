module Types
  class SearchObject < BaseObject
    field :total, Integer, null: false
    field :nodes, [SearchItemObject], null: false
  end
end