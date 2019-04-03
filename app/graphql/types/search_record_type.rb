# frozen_string_literal: true

module Types
  class SearchRecordType < BaseUnion
    graphql_name "SearchRecord"
    description "Objects which may be search result"

    possible_types UserType, DocType, GroupType

    def self.resolve_type(object, context)
      case object.class.name
      when "User"
        Types::UserType
      when "Doc"
        Types::DocType
      when "Group"
        Types::GroupType
      else
        raise "Can't resolve_type for #{object.inspect}"
      end
    end
  end
end
