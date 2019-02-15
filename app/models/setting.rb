# frozen_string_literal: true

# RailsSettings Model
class Setting < RailsSettings::Base
  source Rails.root.join("config/app.yml")

  SEPARATOR_REGEXP = /[\s,]/

  class << self
    def field(*keys, **opts)
      keys = [keys] unless keys.is_a?(Array)

      keys.each do |key|
        if opts[:readonly]
          _define_readonly_field(key)
        else
          _define_field(key, default: opts[:default], type: opts[:type], separator: opts[:separator])
        end
      end
    end

    private
      def _define_field(key, default: nil, type: :string, separator: nil)
        self.class.define_method(key) do
          val = self[key]
          default = default.call if default.is_a?(Proc)
          return default if val.nil?
          val
        end

        if type == :boolean
          self.class.define_method("#{key}?") do
            val = self.send(key.to_sym)
            val == "true" || val == "1"
          end
        elsif type == :array
          self.class.define_method("#{key.to_s.singularize}_list") do
            val = self.send(key.to_sym) || ""
            separator = SEPARATOR_REGEXP if separator.nil?
            val.split(separator).reject { |str| str.empty? }
          end
        end
      end

      def _define_readonly_field(key)
        self.class.define_method(key) do
          val = RailsSettings::Default[key.to_sym]
          default = default.call if default.is_a?(Proc)
          return default if val.nil?
          val
        end
      end
  end

  field :default_locale, default: "en", type: :string
  field :admin_emails, default: "admin@bluedoc.io", type: :array
  field :application_footer_html, default: "", type: :string
  field :dashboard_sidebar_html, default: "", type: :string
  field :anonymous_enable, default: "1", type: :boolean
  field :plantuml_service_host, default: (ENV["PLANTUML_SERVICE_HOST"] || "http://localhost:1608"), type: :string
  field :mathjax_service_host, default: (ENV["MATHJAX_SERVICE_HOST"] || "http://localhost:4010"), type: :string

  # Readonly setting keys, no cache, only load from yml file
  field :host, :mailer_from, :mailer_options, readonly: true
  field :license, default: "", type: :string

  class << self
    LOCALES = {
      "en": "English (US)",
      "zh-CN": "简体中文"
    }

    def has_admin?(email)
      return false if self.admin_email_list.blank?
      self.admin_email_list.include?(email.downcase)
    end

    def locale_options
      LOCALES.map { |k, v| [v, k.to_s] }
    end

    def default_locale_name
      LOCALES[Setting.default_locale.to_sym] || LOCALES[I18n.default_locale]
    end
  end
end
