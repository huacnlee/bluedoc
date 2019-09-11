# frozen_string_literal: true

class Service < ApplicationRecord
  belongs_to :repository
  serialize :properties, Hash
end
