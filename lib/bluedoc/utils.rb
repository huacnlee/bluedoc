module BlueDoc
  class Utils
    class << self
      # Get camelize name for OmniAuth provider
      # LDAP -> Setting.ldap_options["title"]
      # Other -> OmniAuth::Utils.camelize
      def omniauth_camelize(provider)
        provider = provider.to_s

        case provider
        when "ldap"
          return Setting.ldap_options["name"]
        when "google_oauth2"
          return "Google"
        else
          OmniAuth::Utils.camelize(provider)
        end
      end
    end
  end
end