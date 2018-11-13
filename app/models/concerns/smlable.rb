# frozen_string_literal: true

module Smlable
  extend ActiveSupport::Concern

  included do
    has_rich_text :body
    has_rich_text :body_sml
  end

  def body_plain
    body.to_s
  end

  def body_sml_plain
    body_sml.to_s
  end
end
