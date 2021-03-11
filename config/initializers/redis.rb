# frozen_string_literal: true

redis_config = Rails.application.config_for(:redis)
Redis::Objects.redis = Redis.new(url: redis_config["url"])

sidekiq_url = redis_config["url"]
Sidekiq.configure_server do |config|
  config.redis = {url: sidekiq_url, db: 2}
end
Sidekiq.configure_client do |config|
  config.redis = {url: sidekiq_url, db: 2}
end
