# frozen_string_literal: true

require "test_helper"

class Admin::DashboardsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

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

  test "POST /admin/dashboard/reindex" do
    sign_in_admin @user
    assert_enqueued_with job: SearchReindexJob do
      post "/admin/dashboard/reindex"
    end

    assert_redirected_to admin_root_path
  end
end
