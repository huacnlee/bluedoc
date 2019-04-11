# frozen_string_literal: true
require "bluedoc/config"

Rails.application.config.after_initialize do
  BlueDoc::Config.register
end