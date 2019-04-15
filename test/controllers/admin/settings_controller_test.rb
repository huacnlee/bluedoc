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
    get admin_settings_path(_action: "show")
    assert_equal 200, response.status
    assert_select ".ldap-auth-fields", 0

    allow_feature :ldap_auth do
      Setting.stub(:ldap_enable?, true) do
        get admin_settings_path(_action: "show")
      end
      assert_equal 200, response.status
      assert_select ".ldap-auth-fields", 1
    end
  end


  test "POST /admin/settings" do
    setting_params = {
      host: "http://foo.com",
      anonymous_enable: "0",
      confirmable_enable: "0",
      captcha_enable: "0",
      admin_emails: "foo@gmail.com\nbar@gmail.com\n#{@user.email}",
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

    setting_params.each_key do |key|
      assert_equal setting_params[key].strip, Setting.send(key).strip
    end

    get admin_settings_path(_action: "ui")
    assert_equal 200, response.status
    assert_select "select[name='setting[default_locale]']" do
      assert_select "option[selected]" do
        assert_select "[value=?]", "zh-CN"
      end
    end
  end
end
