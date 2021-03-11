# frozen_string_literal: true

require "test_helper"

class Admin::SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in_admin @user
  end

  test "GET /admin/settings" do
    get admin_settings_path
    assert_redirected_to admin_settings_path(_action: "show")
    follow_redirect!

    assert_equal 200, response.status
  end


  test "GET /admin/settings for check :ldap_auth" do
    Setting.stub(:ldap_enable?, true) do
      get admin_settings_path(_action: "show")
    end
    assert_equal 200, response.status
    assert_select ".ldap-auth-fields", 1
  end


  test "POST /admin/settings" do
    setting_params = {
      host: "http://foo.com",
      anonymous_enable: "0",
      confirmable_enable: "0",
      captcha_enable: "0",
      admin_emails: "foo@gmail.com\nbar@gmail.com\n#{@user.email}",
      broadcast_message_html: "<span>hello world</span>",
      application_footer_html: "<span>hello</span>",
      dashboard_sidebar_html: "<span>world</span>",
      plantuml_service_host: "http://my-plantuml.com",
      mathjax_service_host: "http://my-mathjax.com",
      default_locale: "zh-CN",
      ldap_name: "Foo",
      ldap_title: "LDAP Foo",
      ldap_description: "LDAP Foo bar",
      mailer_from: "foo@bar.com",
      mailer_options: <<~YAML
      address: foo.com
      username: foo
      YAML
    }

    post admin_settings_path, params: { setting: setting_params }
    assert_redirected_to admin_settings_path

    assert_equal "http://foo.com", Setting.host
    assert_equal false, Setting.anonymous_enable
    assert_equal false, Setting.confirmable_enable
    assert_equal false, Setting.captcha_enable
    assert_equal ["foo@gmail.com", "bar@gmail.com", @user.email], Setting.admin_emails
    assert_equal "<span>hello world</span>", Setting.broadcast_message_html
    assert_equal "<span>hello</span>", Setting.application_footer_html
    assert_equal "<span>world</span>", Setting.dashboard_sidebar_html
    assert_equal "http://my-plantuml.com", Setting.plantuml_service_host
    assert_equal "http://my-mathjax.com", Setting.mathjax_service_host
    assert_equal "zh-CN", Setting.default_locale
    assert_equal "Foo", Setting.ldap_name
    assert_equal "LDAP Foo", Setting.ldap_title
    assert_equal "LDAP Foo bar", Setting.ldap_description
    assert_equal "foo@bar.com", Setting.mailer_from
    assert_equal({ address: "foo.com", username: "foo" }.deep_stringify_keys, Setting.mailer_options)

    get admin_settings_path(_action: "ui")
    assert_equal 200, response.status
    assert_select "select[name='setting[default_locale]']" do
      assert_select "option[selected]" do
        assert_select "[value=?]", "zh-CN"
      end
    end
  end
end
