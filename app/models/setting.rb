# frozen_string_literal: true

# RailsSettings Model
class Setting < RailsSettings::Base
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
          default_val = default
          default_val = default.call if default.is_a?(Proc)
          if type == :hash
            default_val = YAML.dump(default_val.deep_stringify_keys)
          end
          return default_val if val.nil?
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
        elsif type == :hash
          self.class.define_method("#{key.to_s.singularize}_hash") do
            val = self.send(key.to_sym) || "{}"
            if val.is_a?(String)
              val = YAML.load(val).to_hash rescue {}
            end
            val.deep_symbolize_keys
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

  field :host, type: :string, default: (ENV["APP_HOST"] || "http://localhost:3000")
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

  # ActionMailer
  field :mailer_from, type: :string, default: "no-reply@bluedoc.io"
  field :mailer_delivery_method, type: :string, default: "smtp"
  field :mailer_options, type: :hash, default: {
    address: ENV["SMTP_ADDRESS"],
    port: (ENV["SMTP_PORT"] || 25).to_i,
    domain: ENV["SMTP_DOMAIN"],
    user_name: ENV["SMTP_USERNAME"],
    password: ENV["SMTP_PASSWORD"],
    authentication: ENV["SMTP_AUTHENTICATION"] || "login",
    enable_starttls_auto: (ENV["SMTP_ENABLE_STARTTLS_AUTO"] || "true") == "true",
  }

  # Devise
  field :ldap_options, type: :hash, default: {
    # LDAP server. `:plain` means no encryption. `:simple_tls` represents SSL/TLS
    # (usually on port 636) while `:start_tls` represents StartTLS (usually port 389).
    host: "",
    encryption: "plain",
    port: 389,
    # Typically AD would be 'sAMAccountName' or 'UserPrincipalName', while OpenLDAP is 'uid'.
    base: "dc=example,dc=org",
    uid: "uid",
    # Most LDAP servers require that you supply a complete DN as a binding-credential, along with an authenticator
    # such as a password. But for many applications, you often don’t have a full DN to identify the user.
    # You usually get a simple identifier like a username or an email address, along with a password.
    #
    # - bind_dn - the admin username
    # - password - the admin password
    bind_dn: "cn=admin,dc=example,dc=org",
    password: "admin"
  }
  field :ldap_name, default: "LDAP", type: :string
  field :ldap_title, default: "LDAP Login", type: :string
  field :ldap_description, default: "Enter you LDAP account to login and binding BlueDoc.", type: :string
  field :omniauth_google_client_id, default: (ENV["OMNIAUTH_GOOGLE_CLIENT_ID"] || ""), type: :string
  field :omniauth_google_client_secret, default: (ENV["OMNIAUTH_GOOGLE_CLIENT_SECRET"] || ""), type: :string
  field :omniauth_github_client_id, default: (ENV["OMNIAUTH_GITHUB_CLIENT_ID"] || ""), type: :string
  field :omniauth_github_client_secret, default: (ENV["OMNIAUTH_GITHUB_CLIENT_SECRET"] || ""), type: :string
  field :omniauth_gitlab_client_id, default: (ENV["OMNIAUTH_GITLAB_CLIENT_ID"] || ""), type: :string
  field :omniauth_gitlab_client_secret, default: (ENV["OMNIAUTH_GITLAB_CLIENT_SECRET"] || ""), type: :string
  field :omniauth_gitlab_api_prefix, default: (ENV["OMNIAUTH_GITLAB_API_PREFIX"] || "https://gitlab.com/api/v4"), type: :string

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

    def mailer_sender
      "BlueDoc <#{Setting.mailer_from}>"
    end

    def ldap_enable?
      Setting.ldap_option_hash[:host].present?
    end
  end
end
