# frozen_string_literal: true

class Mutations::MoveToc < Mutations::BaseMutation
  argument :id, ID, required: true, description: "RepositoryToc primary id"
  argument :target_id, ID, required: true, description: "Target RepositoryToc primary id"
  argument :position, String, required: false, default_value: "right", description: "Position, allow: left, right, child"

  type Boolean

  def resolve(id:, target_id:, position: "right")
    @toc = RepositoryToc.find(id)
    @target_toc = @toc.repository.tocs.find(target_id)

    authorize! :create_doc, @toc.repository

    @toc.move_to(@target_toc, position.to_sym)

    true
  end
end
