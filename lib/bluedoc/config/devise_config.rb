# frozen_string_literal: true

module BlueDoc
  class Config
    class DeviseConfig
      class << self
        def register
          config = DeviseConfig.new
          %i[mailer_sender omniauth_configs].each do |name|
            ::Devise.send(:define_singleton_method, name) do
              config.send(name)
            end
          end
        end
      end

      def mailer_sender
        "BlueDoc <#{Setting.mailer_from}>"
      end

      def omniauth_configs
        configs = {}
        if Setting.ldap_enable?
          ldap_options = Setting.ldap_option_hash
          configs[:ldap] = _omniauth(:ldap, ldap_options)
        end

        if Setting.omniauth_google_client_id.present?
          configs[:google_oauth2] = _omniauth(:google_oauth2, Setting.omniauth_google_client_id, Setting.omniauth_google_client_secret)
        end

        if Setting.omniauth_github_client_id.present?
          configs[:github] = _omniauth(:github, Setting.omniauth_github_client_id, Setting.omniauth_github_client_secret)
        end

        if Setting.omniauth_gitlab_client_id.present?
          client_options = {
            site: Setting.omniauth_gitlab_api_prefix || "https://gitlab.com/api/v4"
          }
          configs[:gitlab] = _omniauth(:gitlab, Setting.omniauth_gitlab_client_id, Setting.omniauth_gitlab_client_secret, client_options: client_options)
        end

        configs
      end

      private
        def _omniauth(provider, *args)
          ::Devise::OmniAuth::Config.new(provider, args)
        end
    end
  end
end
