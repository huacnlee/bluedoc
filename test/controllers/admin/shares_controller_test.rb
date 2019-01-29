# frozen_string_literal: true

require "test_helper"

class Admin::SharesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user)
    sign_in_admin @admin

    @share = create(:share)
  end

  test "should get index" do
    get admin_shares_path
    assert_equal 200, response.status
  end

  test "should destroy admin_share" do
    assert_difference("Share.count", -1) do
      delete admin_share_path(@share.id)
    end

    assert_redirected_to admin_shares_path
  end
end
