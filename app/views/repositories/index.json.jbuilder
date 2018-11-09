# frozen_string_literal: true

json.array! @repositories, partial: "repositories/repository", as: :repository
