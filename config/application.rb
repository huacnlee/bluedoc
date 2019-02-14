# frozen_string_literal: true

require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Booklab
  class Application < Rails::Application
    config.load_defaults 6.0

    config.autoload_paths += [
      Rails.root.join("lib")
    ]
    config.eager_load_paths += [
      Rails.root.join("lib/booklab"),
    ]

    # PRO-start
    pro_paths = config.eager_load_paths.each_with_object([]) do |path, memo|
      pro_path = config.root.join("pro", Pathname.new(path).relative_path_from(config.root))
      memo << pro_path.to_s if pro_path.exist?
    end
    config.eager_load_paths.unshift(*pro_paths)
    config.paths["app/views"].unshift("#{config.root}/pro/app/views")
    # PRO-end

    config.i18n.available_locales = ["en", "zh-CN"]
    config.i18n.fallbacks = true

    redis_config = Application.config_for(:redis)
    config.cache_store = [:redis_cache_store, { namespace: "cache-#{redis_config["namespace"]}", url: redis_config["url"], expires_in: 2.weeks }]
  end
end

require "booklab"
