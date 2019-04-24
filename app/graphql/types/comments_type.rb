# frozen_string_literal: true

module Types
  class CommentsType < PaginationType
    field :records, [CommentType], null: false, description: "Comment collection for current page"
  end
end
