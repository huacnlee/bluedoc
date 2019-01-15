# frozen_string_literal: true

class ApplicationController
  before_action :set_locale
  def set_locale
    I18n.locale = user_locale

    # after store current locale
    cookies[:locale] = params[:locale] if params[:locale]
  rescue I18n::InvalidLocale
    I18n.locale = I18n.default_locale
  end

  private
    def user_locale
      params[:locale] || cookies[:locale] || http_head_locale || Setting.default_locale || I18n.default_locale
    end

    def http_head_locale
      return nil if !Setting.auto_locale?
      http_accept_language.language_region_compatible_from(I18n.available_locales)
    end
end
