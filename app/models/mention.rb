# frozen_string_literal: true

class Mention < ApplicationRecord
  belongs_to :mentionable, polymorphic: true
end
