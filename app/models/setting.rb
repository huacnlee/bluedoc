# frozen_string_literal: true

# RailsSettings Model
class Setting < RailsSettings::Base
  field :host, type: :string, default: (ENV["APP_HOST"] || "http://localhost:3000")
  field :site_logo, type: :string
  field :default_locale, default: "en", type: :string
  field :admin_emails, default: ["admin@bluedoc.io"], type: :array
  field :broadcast_message_html, default: "", type: :string
  field :application_footer_html, default: "", type: :string
  field :dashboard_sidebar_html, default: "", type: :string
  field :anonymous_enable, default: true, type: :boolean
  field :plantuml_service_host, default: (ENV["PLANTUML_SERVICE_HOST"] || "http://localhost:1608"), type: :string
  field :mathjax_service_host, default: (ENV["MATHJAX_SERVICE_HOST"] || "http://localhost:4010"), type: :string
  field :confirmable_enable, default: false, type: :boolean
  field :user_email_suffixes, default: [], type: :array
  field :captcha_enable, default: true, type: :boolean

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
    enable_starttls_auto: (ENV["SMTP_ENABLE_STARTTLS_AUTO"] || "true") == "true"
  }

  # Devise
  field :ldap_options, type: :hash, default: {
    # LDAP server. `:plain` means no encryption. `:simple_tls` represents SSL/TLS
    # (usually on port 636) while `:start_tls` represents StartTLS (usually port 389).
    host: (ENV["LDAP_HOST"] || ""),
    encryption: (ENV["LDAP_ENCRYPTION"] || "plain"),
    port: (ENV["LDAP_PORT"] || 389).to_i,
    # Typically AD would be 'sAMAccountName' or 'UserPrincipalName', while OpenLDAP is 'uid'.
    base: (ENV["LDAP_BASE"] || "dc=example,dc=org"),
    uid: (ENV["LDAP_UID"] || "uid"),
    # Most LDAP servers require that you supply a complete DN as a binding-credential, along with an authenticator
    # such as a password. But for many applications, you often don’t have a full DN to identify the user.
    # You usually get a simple identifier like a username or an email address, along with a password.
    #
    # - bind_dn - the admin username
    # - password - the admin password
    bind_dn: (ENV["LDAP_BIND_DN"] || "cn=admin,dc=example,dc=org"),
    password: (ENV["LDAP_PASSWORD"] || "admin")
  }, readonly: true
  field :ldap_name, default: "LDAP", type: :string
  field :ldap_title, default: "LDAP Login", type: :string
  field :ldap_description, default: "Enter you LDAP account to login and binding BlueDoc.", type: :string
  field :omniauth_google_client_id, default: (ENV["OMNIAUTH_GOOGLE_CLIENT_ID"] || ""), type: :string, readonly: true
  field :omniauth_google_client_secret, default: (ENV["OMNIAUTH_GOOGLE_CLIENT_SECRET"] || ""), type: :string, readonly: true
  field :omniauth_github_client_id, default: (ENV["OMNIAUTH_GITHUB_CLIENT_ID"] || ""), type: :string, readonly: true
  field :omniauth_github_client_secret, default: (ENV["OMNIAUTH_GITHUB_CLIENT_SECRET"] || ""), type: :string, readonly: true
  field :omniauth_gitlab_client_id, default: (ENV["OMNIAUTH_GITLAB_CLIENT_ID"] || ""), type: :string, readonly: true
  field :omniauth_gitlab_client_secret, default: (ENV["OMNIAUTH_GITLAB_CLIENT_SECRET"] || ""), type: :string, readonly: true
  field :omniauth_gitlab_api_prefix, default: (ENV["OMNIAUTH_GITLAB_API_PREFIX"] || "https://gitlab.com/api/v4"), type: :string, readonly: true

  class << self
    LOCALES = {
      "en": "English (US)",
      "zh-CN": "简体中文"
    }

    def has_admin?(email)
      return false if admin_emails.blank?
      admin_emails.include?(email.downcase)
    end

    def locale_options
      LOCALES.map { |k, v| [v, k.to_s] }
    end

    def default_locale_name
      LOCALES[Setting.default_locale.to_sym] || LOCALES[I18n.default_locale]
    end

    def user_email_limit_enable?
      user_email_suffixes.any?
    end

    # Check User email by user_email_suffixes setting
    def valid_user_email?(email)
      return false if email.blank?
      return true if user_email_suffixes.blank?

      found = false

      user_email_suffixes.each do |suffix|
        if email.downcase.end_with?(suffix.downcase)
          found = true
          break
        end
      end

      found
    end

    def mailer_sender
      "BlueDoc <#{Setting.mailer_from}>"
    end

    def ldap_enable?
      Setting.ldap_options[:host].present?
    end
  end
end
