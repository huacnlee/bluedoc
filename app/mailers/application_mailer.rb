# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "BlueDoc <#{Setting.mailer_from}>"
  default_url_options[:host] = Setting.host

  layout "mailer"
end
