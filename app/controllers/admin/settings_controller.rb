# frozen_string_literal: true

class Admin::SettingsController < Admin::ApplicationController
  def show
    @setting = Setting.unscoped.first || Setting.new
  end

  def create
    setting_params.keys.each do |key|
      Setting.send("#{key}=", setting_params[key]) unless setting_params[key].nil?
    end
    redirect_to admin_settings_path, notice: "Setting was successfully updated"
  end

  private
    def setting_params
      params.require(:setting).permit(:admin_emails, :application_footer_html, :dashboard_sidebar_html, :anonymous_enable,
        :plantuml_service_host, :mathjax_service_host)
    end
end
