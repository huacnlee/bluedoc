# frozen_string_literal: true

class Repository
  serialize :preferences, Hash

  store_accessor :preferences, :has_toc, :has_issues
end
