# frozen_string_literal: true

class Admin::SettingsController < Admin::ApplicationController
  def show
    case params[:_action]
    when "mailer"
      render "mailer"
    when "ui"
      render "ui"
    when "show"
      render :show
    else
      redirect_to admin_settings_path(_action: "show")
    end
  end

  def create
    if setting_params[:site_logo]
      content_type = setting_params[:site_logo].content_type
      Setting.site_logo = "data:#{content_type};base64,#{Base64.encode64(setting_params[:site_logo].read)}"
    end

    setting_params.keys.each do |key|
      next if key.to_s == "site_logo"
      Setting.send("#{key}=", setting_params[key].strip) unless setting_params[key].nil?
    end
    redirect_to admin_settings_path(_action: params[:_action]), notice: t(".Setting was successfully updated")
  end

  def test_mail
    UserMailer.with(user: current_user).test.deliver_later
    redirect_to admin_settings_path(_action: "mailer"), notice: "Test email has sent to #{current_user.email}"
  end

  private

  def setting_params
    params.require(:setting).permit(:host, :default_locale, :admin_emails,
      :broadcast_message_html, :application_footer_html, :dashboard_sidebar_html, :anonymous_enable,
      :plantuml_service_host, :mathjax_service_host, :confirmable_enable, :user_email_suffixes,
      :captcha_enable, :ldap_name, :ldap_title, :ldap_description, :ldap_options,
      :mailer_from, :mailer_options, :site_logo)
  end
end
