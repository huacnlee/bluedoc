# frozen_string_literal: true

Rails.application.config.cache_store = :redis_cache_store, { url: ENV["REDIS_URL"] }