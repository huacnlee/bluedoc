class Types::Mutation < Query::BaseQuery
  field :delete_doc, mutation: Mutations::DeleteDoc
end
