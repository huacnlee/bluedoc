module InlineCommentable
  extend ActiveSupport::Concern

  included do
    has_many :inline_comments, as: :subject
  end
end