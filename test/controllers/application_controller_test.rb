# frozen_string_literal: true

require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "locale" do
    # default to en
    get new_user_session_path
    assert_locale_equal "en"

    # use Setting.default_locale
    Setting.stub(:default_locale, "zh-CN") do
      get new_user_session_path
      assert_locale_equal "zh-CN"
    end

    # Setting.default_locale invalid, fallback to en
    Setting.stub(:default_locale, "foo") do
      get new_user_session_path
      assert_locale_equal "en"
    end

    # sign user
    user = create(:user, locale: "")
    sign_in user

    # locale has not setup yet, use en (I18n.default_locale)
    get root_path
    assert_locale_equal "en"

    # locale has not setup yet, use en (Setting.default_locale)
    Setting.stub(:default_locale, "zh-CN") do
      get root_path
      assert_locale_equal "zh-CN"
    end

    # User set locale to en, use it first
    user.update(locale: "en")
    Setting.stub(:default_locale, "zh-CN") do
      get root_path
      assert_locale_equal "en"
    end

    # User has a invalid locale, fallback to Setting.default_locale
    user.update(locale: "en1")
    Setting.stub(:default_locale, "zh-CN") do
      get root_path
      assert_locale_equal "zh-CN"
    end

    # User has a invalid locale, fallback to Setting.default_locale, and fallback to I18n.default_locale
    user.update(locale: "en1")
    get root_path
    assert_locale_equal "en"
  end

  private
    def assert_locale_equal(locale)
      assert_equal 200, response.status
      assert_select "meta[name=locale]" do
        assert_select "[content=?]", locale
      end
    end
end