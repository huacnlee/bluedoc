class Types::Query < GraphQL::Schema::Object
  # Add root-level fields here.
  # They will be entry points for queries on your schema.

  depends_on :search, :docs
end