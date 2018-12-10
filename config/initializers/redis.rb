# frozen_string_literal: true

redis_config = Rails.application.config_for(:redis)
Redis::Objects.redis = Redis.new(url: redis_config["url"])
