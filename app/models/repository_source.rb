# frozen_string_literal: true

class RepositorySource < ApplicationRecord
  belongs_to :repository

  enum status: %i[running done failed]
end
