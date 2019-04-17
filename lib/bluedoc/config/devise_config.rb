# frozen_string_literal: true

module BlueDoc
  class Config
    class DeviseConfig
      class << self
        def register
          config = DeviseConfig.new
          %i[mailer_sender].each do |name|
            ::Devise.send(:define_singleton_method, name) do
              config.send(name)
            end
          end
        end
      end

      def mailer_sender
        "BlueDoc <#{Setting.mailer_from}>"
      end
    end
  end
end
