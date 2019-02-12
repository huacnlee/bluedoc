module Types
  class SearchObject < BaseObject
    field :total, Integer, null: false
    field :records, [SearchRecordObject], null: false
  end
end