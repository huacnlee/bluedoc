module BlueDoc
  class Config
    class ApplicationConfig
      def self.register
        config = ApplicationConfig.new

        %i[action_mailer].each do |name|
          Rails.application.config.send(:define_singleton_method, name) do
            config.send(name)
          end
        end
      end

      def initialize
        @base_config = Rails.application.config.dup
      end

      def action_mailer
        fetch_config(:action_mailer, {
          delivery_method: Setting.mailer_delivery_method.to_sym,
          smtp_settings: Setting.mailer_option_hash.deep_symbolize_keys,
          default_url_options: {
            host: Setting.host,
          }
        })
      end

      private
        def fetch_config(name, new_config)
          @base_config.send(name).merge(new_config)
        end
    end
  end
end