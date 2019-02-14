# frozen_string_literal: true

require "test_helper"

class Admin::ProDashboardsControllerTest < ActionDispatch::IntegrationTest
  test "GET /admin" do
    user = create(:user)
    sign_in_admin user
    get "/admin"
    assert_equal 200, response.status

    assert_select "#license-info" do
      assert_select ".btn[href='/admin/licenses']", text: "Add License"
    end
  end
end