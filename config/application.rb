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
      Rails.root.join("lib/bluedoc"),
    ]

    config.autoloader = :classic

    # PRO-start
    # Need enable config.eager_load = true in all environments for load libs on boot
    pro_paths = config.eager_load_paths.each_with_object([]) do |path, memo|
      pro_path = config.root.join("pro", Pathname.new(path).relative_path_from(config.root))
      memo << pro_path.to_s if pro_path.exist?
    end
    config.eager_load_paths.unshift(*pro_paths)

    config.paths["app/views"].unshift("#{config.root}/pro/app/views")
    # PRO-end

    config.to_prepare do
      Devise::Mailer.layout "mailer"
    end

    config.i18n.available_locales = ["en", "zh-CN"]
    config.i18n.fallbacks = true
  end
end

require "bluedoc"
