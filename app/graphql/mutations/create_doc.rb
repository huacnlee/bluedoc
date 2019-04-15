# frozen_string_literal: true

class Mutations::CreateDoc < Mutations::BaseMutation
  argument :repository_id, ID, required: true, description: "Repository primary id"
  argument :slug, String, required: false, description: "Slug if you want give"

  type ::Types::DocType

  def resolve(repository_id:, slug: nil)
    @repository = Repository.find(repository_id)

    authorize! :create_doc, @repository

    @doc = Doc.create_new(@repository, current_user.id, slug: slug)

    @doc
  end
end
