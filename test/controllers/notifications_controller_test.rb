# frozen_string_literal: true

require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "require login" do
    assert_require_user do
      get notifications_path
    end
  end

  test "GET /" do
    sign_in @user

    create_list(:notification, 2, user: @user, notify_type: :add_member)
    create_list(:notification, 2, user: @user, notify_type: :add_member, read_at: Time.now)
    create_list(:notification, 1, notify_type: :add_member)

    get notifications_path
    assert_equal 200, response.status
    assert_select ".notifications"
    assert_select ".Box-header .title", text: "Unread notifications"
    assert_select ".notification", 2

    get notifications_path, params: { tab: :all }
    assert_equal 200, response.status
    assert_select ".notifications"
    assert_select ".Box-header .title", text: "All notifications"
    assert_select ".notification", 4

    get notifications_path
    assert_equal 200, response.status
    assert_select ".notification", 0

    delete clean_notifications_path
    assert_equal 0, Notification.where(user_id: @user.id).count
  end
end