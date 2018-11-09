# frozen_string_literal: true

require "test_helper"

class Admin::DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in @user
  end

  test "GET /admin" do
    get "/admin"
    assert_equal 403, response.status

    sign_in_admin @user
    get "/admin"
    assert_equal 200, response.status
  end
end
