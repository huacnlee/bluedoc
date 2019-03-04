# frozen_string_literal: true

class Admin::SettingsController < Admin::ApplicationController
  def show
  end

  def create
    setting_params.keys.each do |key|
      Setting.send("#{key}=", setting_params[key].strip) unless setting_params[key].nil?
    end
    redirect_to admin_settings_path, notice: t(".Setting was successfully updated")
  end

  private
    def setting_params
      params.require(:setting).permit(:default_locale, :admin_emails, :application_footer_html, :dashboard_sidebar_html, :anonymous_enable,
        :plantuml_service_host, :mathjax_service_host, :confirmable_enable, :user_email_suffixes)
    end
end
