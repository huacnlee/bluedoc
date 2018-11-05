# frozen_string_literal: true

# Be sure to restart your server when you modify this file.
Rails.application.config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
