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

  test "confirmable_enable" do
    assert_equal "0", Setting.confirmable_enable
    assert_equal false, Setting.confirmable_enable?

    Setting.confirmable_enable = "1"
    assert_equal true, Setting.confirmable_enable?

    Setting.confirmable_enable = "0"
    assert_equal false, Setting.confirmable_enable?
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
      allow_feature(:limit_user_emails) do
        assert_equal false, Setting.valid_user_email?(nil)
        assert_equal false, Setting.valid_user_email?("aaa@gmail.com")
        assert_equal true, Setting.valid_user_email?("aaa@foo.com")
        assert_equal true, Setting.valid_user_email?("bbb@Foo.Com")
        assert_equal true, Setting.valid_user_email?("ccc@bar.Com")
        assert_equal true, Setting.user_email_limit_enable?
      end

      # return true when now allow :limit_user_emails feature
      assert_equal false, Setting.user_email_limit_enable?
      assert_equal false, Setting.valid_user_email?(nil)
      assert_equal true, Setting.valid_user_email?("aaa@gmail.com")
      assert_equal true, Setting.valid_user_email?("aaa@aaa.com")
      assert_equal true, Setting.valid_user_email?("bbb@bbb.Com")
    end
  end

  test "user_email_limit_enable?" do
    allow_feature(:limit_user_emails) do
      assert_equal false, Setting.user_email_limit_enable?
      Setting.stub(:user_email_suffixes, "foo.com,Bar.com") do
        assert_equal true, Setting.user_email_limit_enable?
      end
    end
  end

  test "mailer_sender" do
    Setting.stub(:mailer_from, "foo@bar.com") do
      assert_equal "BlueDoc <foo@bar.com>", Setting.mailer_sender
    end

    Setting.stub(:mailer_from, "bar@foo.com") do
      assert_equal "BlueDoc <bar@foo.com>", Setting.mailer_sender
    end
  end

  test "ldap_options" do
    assert_kind_of String, Setting.ldap_options
    assert_kind_of Hash, Setting.ldap_option_hash
    Setting.ldap_options = <<~YAML
    host: "foo.com"
    encryption: "aaa"
    YAML
    assert_equal "foo.com", Setting.ldap_option_hash[:host]
    assert_equal "aaa", Setting.ldap_option_hash[:encryption]
  end

  test "mailer_options" do
    assert_kind_of String, Setting.mailer_options
    assert_kind_of Hash, Setting.mailer_option_hash
    Setting.mailer_options = <<~YAML
    address: "foo.com"
    user_name: "aaa"
    YAML

    assert_equal "foo.com", Setting.mailer_option_hash[:address]
    assert_equal "aaa", Setting.mailer_option_hash[:user_name]
  end
end
