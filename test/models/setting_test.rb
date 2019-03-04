# frozen_string_literal: true

require "test_helper"

class SettingTest < ActiveSupport::TestCase
  test "anonymous_enable" do
    assert_equal "1", Setting.anonymous_enable
    assert_equal true, Setting.anonymous_enable?

    Setting.anonymous_enable = "0"
    assert_equal false, Setting.anonymous_enable?

    Setting.anonymous_enable = "1"
    assert_equal true, Setting.anonymous_enable?
  end

  test "has_admin?" do
    Setting.admin_emails = "admin@gitbook.io\nhuacnlee@gmail.com"
    assert_equal 2, Setting.admin_email_list.length
    assert_equal %w[admin@gitbook.io huacnlee@gmail.com], Setting.admin_email_list
    assert_equal true, Setting.has_admin?("admin@gitbook.io")
    assert_equal true, Setting.has_admin?("huacnlee@gmail.com")
    assert_equal false, Setting.has_admin?("foo@gmail.com")
  end

  test "application_footer_html" do
    Setting.application_footer_html = "<span>hello</span>"
    assert_equal "<span>hello</span>", Setting.application_footer_html
  end

  test "plantuml_service_host" do
    assert_equal "http://localhost:1608", Setting.plantuml_service_host
    Setting.plantuml_service_host = "http://127.0.0.1:1608"
    assert_equal "http://127.0.0.1:1608", Setting.plantuml_service_host
  end

  test "readonly fields" do
    default = RailsSettings::Default
    %i[host mailer_from mailer_options].each do |field|
      assert_equal default[field], Setting.send(field), "Setting.#{field.to_s} should be #{default[field]}"
      Setting.send("#{field}=", "123")
      assert_equal default[field], Setting.send(field), "Setting.#{field.to_s} should be #{default[field]}"
    end
  end

  test "default_locale" do
    assert_equal [["English (US)", "en"], ["简体中文", "zh-CN"]], Setting.locale_options
    Setting.stub(:default_locale, "zh-CN") do
      assert_equal "简体中文", Setting.default_locale_name
    end
    Setting.stub(:default_locale, "en") do
      assert_equal "English (US)", Setting.default_locale_name
    end
    Setting.stub(:default_locale, "foo") do
      assert_equal "English (US)", Setting.default_locale_name
    end
  end

  test "valid_user_email?" do
    assert_equal "", Setting.user_email_suffixes
    assert_equal [], Setting.user_email_suffix_list
    assert_equal true, Setting.valid_user_email?("foo")

    Setting.stub(:user_email_suffixes, "foo.com,Bar.com") do
      assert_equal ["foo.com", "Bar.com"], Setting.user_email_suffix_list
      assert_equal false, Setting.valid_user_email?(nil)
      assert_equal false, Setting.valid_user_email?("aaa@gmail.com")
      assert_equal true, Setting.valid_user_email?("aaa@foo.com")
      assert_equal true, Setting.valid_user_email?("bbb@Foo.Com")
      assert_equal true, Setting.valid_user_email?("ccc@bar.Com")
    end
  end
end
