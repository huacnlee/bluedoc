require "bluedoc/config/application_config"
require "bluedoc/config/devise_config"
require "bluedoc/config/application_mailer_config"

module BlueDoc
  # Rewrite Rails application configs for supports change configs after boot
  class Config
    def self.register
      Rails.logger.info "BlueDoc::Config registing..."

      ApplicationConfig.register
      DeviseConfig.register
      ApplicationMailerConfig.register
    end
  end
end
