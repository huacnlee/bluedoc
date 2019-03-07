# frozen_string_literal: true

require "test_helper"

class Users::PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "GET /passwords/new" do
    get new_user_password_path
    assert_equal 200, response.status
    assert_select ".heading", text: "Reset password"

    user = create(:user)

    form_params = {
      email: user.email,
    }
    post user_password_path, params: { user: form_params }
    assert_equal 200, response.status
    assert_match /Captcha invalid/, response.body

    ActionController::Base.any_instance.stubs(:verify_rucaptcha?).returns(true)
    post user_password_path, params: { user: form_params }
    assert_redirected_to new_user_session_path

    user.reload

    assert_not_nil user.reset_password_token
    assert_not_nil user.reset_password_sent_at
  end
end
