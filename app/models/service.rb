# frozen_string_literal: true

class Service < ApplicationRecord
  serialize :properties, Hash
end
