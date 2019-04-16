# frozen_string_literal: true

module BlueDoc
  class Utils
    class << self
      # Get camelize name for OmniAuth provider
      # LDAP -> Setting.ldap_title
      # Other -> OmniAuth::Utils.camelize
      def omniauth_camelize(provider)
        provider = provider.to_s

        case provider
        when "ldap"
          return Setting.ldap_name
        when "google_oauth2"
          return "Google"
        else
          OmniAuth::Utils.camelize(provider)
        end
      end

      # Generate random HEX color
      # for example: #EA09DD
      def random_color
        "##{Random.new.bytes(3).unpack("H*")[0]}"
      end

      # Valid hex color
      def valid_color?(color)
        /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/.match?(color)
      end

      # huashun.li -> Huashun Li
      # huashun-li -> Huashun Li
      def humanize_name(slug)
        return nil if slug.nil?

        slug.split(/[\-\.\s]/).map { |s| s.humanize }.join(" ")
      end
    end
  end
end
