module Types
  class SearchRecordObject < BaseUnion
    graphql_name "SearchRecord"
    description "Objects which may be search result"

    possible_types UserObject, DocObject

    def self.resolve_type(object, context)
      if object.is_a?(User)
        Types::UserObject
      elsif object.is_a?(Doc)
        Types::DocObject
      else
        Types::UserObject
      end
    end
  end
end