class Mutations::DeleteDoc < Mutations::BaseMutation
  null true

  argument :id, ID, required: true

  def resolve(id:)
    @doc = Doc.find(id)

    authorize! :destroy, @doc

    @doc.destroy

    { id: id }
  end
end
