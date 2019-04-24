# frozen_string_literal: true

module Queries
  class QueryType < BaseQuery
    field :inline_comment, Types::InlineCommentType, null: true, description: "Get InlineComment by id" do
      argument :id, Integer, required: true
    end

    def inline_comment(id:)
      @inline_comment = InlineComment.find(id)
      authorize! :read, @inline_comment

      @inline_comment
    end

    field :inline_comments, [Types::InlineCommentType], null: true, description: "Get all created InlineComment list for subject (Doc, Note)" do
      argument :subject_type, String, required: true, description: "Subject type, allow: [Doc]"
      argument :subject_id, ID, required: true, description: "Subject primary key"
    end
    def inline_comments(subject_type:, subject_id:)
      if subject_type != "Doc"
        raise "Not implement to support subject_type: #{subject_type}"
      end

      @doc = Doc.find(subject_id)
      authorize! :read, @doc

      @doc.inline_comments.where("comments_count > 0").includes(:user)
    end
  end
end
