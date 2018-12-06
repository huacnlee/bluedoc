# frozen_string_literal: true

module Reactionable
  extend ActiveSupport::Concern

  included do
    has_many :reactions, as: :subject, dependent: :destroy
  end
end
