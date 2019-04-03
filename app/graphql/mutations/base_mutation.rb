class Mutations::BaseMutation < GraphQL::Schema::RelayClassicMutation
  include ::Types::QueryAuth

  # Add your custom classes if you have them:
  # This is used for generating payload types
  object_class Types::BaseType
  # This is used for return fields on the mutation's payload
  field_class GraphQL::Schema::Field
  # This is used for generating the `input: { ... }` object type
  input_object_class Types::BaseInputObject
end
