# frozen_string_literal: true

class Mutations::CreateInlineComment < Mutations::BaseMutation
  argument :subject_type, String, required: true, description: "Subject type, allow: [Doc]"
  argument :subject_id, ID, required: true, description: "Subject primary key"
  argument :nid, String, required: false, description: "Content node id (nid)"

  type ::Types::InlineCommentType

  def resolve(subject_type:, subject_id:, nid:)
    if subject_type != "Doc"
      raise "Not implement to support subject_type: #{subject_type}"
    end

    @doc = Doc.find(subject_id)
    authorize! :create_comment, @doc

    InlineComment.create_or_find_by!(subject: @doc, nid: nid) do |inline_comment|
      inline_comment.user_id = current_user.id
    end
  end
end
