# frozen_string_literal: true

class ApplicationController
  helper_method :rucaptcha_enable?

  def rucaptcha_enable?
    Setting.captcha_enable?
  end

  def verify_captcha?(resource)
    return true unless rucaptcha_enable?

    verify_rucaptcha?(resource)
  end
end
