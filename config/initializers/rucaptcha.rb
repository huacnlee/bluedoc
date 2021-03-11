# frozen_string_literal: true

redis_config = Rails.application.config_for(:redis)

RuCaptcha.configure do
  self.cache_store = [:redis_cache_store, {namespace: "rucaptcha-#{redis_config["namespace"]}", url: redis_config["url"], expires_in: 2.weeks}]
end
