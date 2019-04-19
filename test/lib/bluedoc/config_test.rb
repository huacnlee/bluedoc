# frozen_string_literal: true

require "test_helper"

class BlueDoc::ConfigTest < ActiveSupport::TestCase
  test "Rails.application.config.action_mailer" do
    assert_equal :test, Rails.application.config.action_mailer.delivery_method

    mailer_options = {
      foo: "aaa",
      bar: "bbb"
    }
    Setting.stub(:mailer_option_hash, mailer_options) do
      assert_equal(mailer_options, Rails.application.config.action_mailer.smtp_settings)
    end

    Setting.stub(:host, "http://bluedoc-test.com") do
      assert_equal({ host: "http://bluedoc-test.com" }, Rails.application.config.action_mailer.default_url_options)
    end
  end

  test "Devise.mailer_sender" do
    Setting.stub(:mailer_from, "Foo@bar.com") do
      assert_equal "BlueDoc <Foo@bar.com>", Devise.mailer_sender
    end
    Setting.stub(:mailer_from, "aaa@bbb.com") do
      assert_equal "BlueDoc <aaa@bbb.com>", Devise.mailer_sender
    end
  end

  test "ApplicationMailer.default_url_options" do
    assert_equal({ host: Setting.host }, ApplicationMailer.default_url_options)
    assert_equal({ host: Setting.host }, ActionMailer::Base.default_url_options)

    mailer_options = {
      foo: "aaa",
      bar: "bbb"
    }
    Setting.stub(:mailer_option_hash, mailer_options) do
      assert_equal(mailer_options, ActionMailer::Base.smtp_settings)
    end
  end
end
