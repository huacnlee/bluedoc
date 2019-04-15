# frozen_string_literal: true

class Mutations::DeleteToc < Mutations::BaseMutation
  argument :id, ID, required: true, description: "Toc primary id"

  type Boolean

  def resolve(id:)
    @toc = Toc.find(id)

    authorize! :create_doc, @toc.repository

    @toc.destroy

    true
  end
end
