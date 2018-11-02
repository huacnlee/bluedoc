# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  default_url_options[:host] = Setting.host

  layout "mailer"
end
