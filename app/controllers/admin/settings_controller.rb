# frozen_string_literal: true

class Admin::SettingsController < Admin::ApplicationController
  ALLOW_KEYS = %i[admin_emails]
  def show
    @setting = Setting.unscoped.first || Setting.new
  end

  def create
    ALLOW_KEYS.each do |key|
      Setting.send("#{key}=", params[key]) if params[key]
    end
    redirect_to admin_settings_path
  end
end
