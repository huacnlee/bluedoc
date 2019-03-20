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
  field :confirmable_enable, default: "1", type: :boolean
  field :user_email_suffixes, default: "", type: :array
  field :captcha_enable, default: "1", type: :boolean
  field :license, default: "", type: :string

  # Readonly setting keys, no cache, only load from yml file
  field :host, :mailer_from, :mailer_options, :ldap_options, readonly: true

  field :ldap_name, default: "LDAP", type: :string
  field :ldap_title, default: "LDAP Login", type: :string
  field :ldap_description, default: "Enter you LDAP account to login and binding BlueDoc.", type: :string

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

    # PRO-begin
    def user_email_limit_enable?
      License.allow_feature?(:limit_user_emails) && self.user_email_suffix_list.any?
    end

    # Check User email by user_email_suffixes setting
    def valid_user_email?(email)
      return false if email.blank?
      return true unless License.allow_feature?(:limit_user_emails)
      return true if self.user_email_suffix_list.blank?

      found = false

      self.user_email_suffix_list.each do |suffix|
        if email.downcase.end_with?(suffix.downcase)
          found = true
          break
        end
      end

      found
    end
    # PRO-end

    def ldap_enable?
      Setting.ldap_options["host"].present?
    end
  end
end
