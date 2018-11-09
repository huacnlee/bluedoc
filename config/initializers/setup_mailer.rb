# frozen_string_literal: true

Rails.application.config.action_mailer.default_url_options = {
  host: Setting.host,
}
