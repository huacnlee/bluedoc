# frozen_string_literal: true

require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Booklab
  class Application < Rails::Application
    config.load_defaults 5.2

    config.autoload_paths += [
      Rails.root.join("lib")
    ]
    config.eager_load_paths += [
      Rails.root.join("lib/booklab"),
    ]

    redis_config = Application.config_for(:redis)
    config.cache_store = [:redis_cache_store, { namespace: "cache-#{redis_config["namespace"]}", url: redis_config["url"], expires_in: 2.weeks }]
  end
end

require "booklab"
