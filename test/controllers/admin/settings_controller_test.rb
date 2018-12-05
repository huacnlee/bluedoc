# frozen_string_literal: true

require "test_helper"

class Admin::SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "POST /admin/settings" do
    setting_params = {
      anonymous_enable: "0",
      admin_emails: "foo@gmail.com\nbar@gmail.com",
      application_footer_html: "<span>hello</span>",
      dashboard_sidebar_html: "<span>world</span>"
    }

    sign_in_admin @user
    post admin_settings_path, params: { setting: setting_params }
    assert_redirected_to admin_settings_path

    setting_params.each_key do |key|
      assert_equal setting_params[key], Setting.send(key)
    end
  end
end