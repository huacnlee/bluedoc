# frozen_string_literal: true

class Mutations::MoveDoc < Mutations::BaseMutation
  argument :id, ID, required: true
  argument :target_id, ID, required: true, description: "Target doc id"
  argument :position, String, required: false, default_value: "right", description: "Position, allow: left, right, child"

  type Boolean

  def resolve(id:, target_id:, position: "right")
    @doc = Doc.find(id)
    @target_doc = @doc.repository.docs.find(target_id)

    authorize! :update, @doc

    @doc.move_to(@target_doc, position.to_sym)

    true
  end
end
