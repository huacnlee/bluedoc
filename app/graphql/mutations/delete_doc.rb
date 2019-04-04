# frozen_string_literal: true

class Mutations::DeleteDoc < Mutations::BaseMutation
  argument :id, ID, required: true

  type Boolean

  def resolve(id:)
    @doc = Doc.find(id)

    authorize! :destroy, @doc

    @doc.destroy

    true
  end
end
