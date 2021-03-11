# frozen_string_literal: true

class ApplicationController
  before_action :set_locale

  def set_locale
    I18n.locale = user_locale
  rescue I18n::InvalidLocale
    use_fallback_locale
  end

  private

  def user_locale
    return current_user&.locale if current_user&.locale.present?

    Setting.default_locale || I18n.default_locale
  end

  def use_fallback_locale
    I18n.locale = Setting.default_locale
  rescue I18n::InvalidLocale
    I18n.locale = I18n.default_locale
  end
end
