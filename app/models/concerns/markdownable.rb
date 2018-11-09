# frozen_string_literal: true

module Markdownable
  extend ActiveSupport::Concern
  include ActionView::Helpers::OutputSafetyHelper
  include ApplicationHelper

  included do
  end

  def body_html
    markdown(body_plain)
  end

  def body_plain
    body&.body&.to_plain_text
  end
end
