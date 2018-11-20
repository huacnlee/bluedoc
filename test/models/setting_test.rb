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
end