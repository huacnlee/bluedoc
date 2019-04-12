# frozen_string_literal: true

module BlueDoc
  class Config
    class ApplicationMailerConfig
      class << self
        def register
          config = ApplicationMailerConfig.new
          %i[default_url_options].each do |name|
            ::ApplicationMailer.send(:define_singleton_method, name) do
              config.send(name)
            end
          end
        end
      end

      def default_url_options
        {
          host: Setting.host,
        }
      end
    end
  end
end
