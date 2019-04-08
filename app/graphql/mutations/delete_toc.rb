# frozen_string_literal: true

class Mutations::DeleteToc < Mutations::BaseMutation
  argument :id, ID, required: true, description: "RepositoryToc primary id"

  type Boolean

  def resolve(id:)
    @toc = RepositoryToc.find(id)

    authorize! :create_doc, @toc.repository

    @toc.destroy

    true
  end
end
