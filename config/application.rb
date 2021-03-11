# frozen_string_literal: true

require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module BlueDoc
  class Application < Rails::Application
    config.load_defaults "6.0"

    config.autoload_paths += [
      Rails.root.join("lib")
    ]
    config.eager_load_paths += [
      Rails.root.join("app/models/project_services"),
      Rails.root.join("lib/bluedoc"),
    ]

    config.autoloader = :classic

    config.to_prepare do
      Devise::Mailer.layout "mailer"
    end

    config.i18n.available_locales = ["en", "zh-CN"]
    config.i18n.fallbacks = true

    redis_config = Application.config_for(:redis)
    config.cache_store = [:redis_cache_store, { namespace: "cache-#{redis_config["namespace"]}", url: redis_config["url"], expires_in: 2.weeks }]
  end
end

require "bluedoc"
