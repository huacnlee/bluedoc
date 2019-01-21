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

    unread_notes = create_list(:notification, 2, user: @user, notify_type: :add_member)
    create_list(:notification, 2, user: @user, notify_type: :add_member, read_at: Time.now)
    other_notes = create_list(:notification, 1, notify_type: :add_member)

    get notifications_path
    assert_equal 200, response.status
    assert_select ".notifications"
    assert_select ".subhead h2", text: "Unread"
    assert_select %(input[name="ids[]"]), 2
    assert_select ".subhead form button", text: "Mark as read"

    assert_select ".notification", 2
    assert_select ".menu .menu-item .counter", text: "2"

    get notifications_path, params: { tab: :all }
    assert_equal 200, response.status
    assert_select ".notifications"
    assert_select ".subhead h2", text: "All"
    assert_select ".notification", 4

    ids = unread_notes.collect(&:id)
    ids << other_notes.collect(&:id)
    post read_notifications_path, params: { ids: unread_notes.collect(&:id) }
    unread_notes.each do |note|
      note.reload
      assert_not_nil note.read_at
    end
    other_notes.each do |note|
      note.reload
      assert_nil note.read_at
    end

    get notifications_path
    assert_equal 200, response.status
    assert_select ".notification", 0

    delete clean_notifications_path
    assert_equal 0, Notification.where(user_id: @user.id).count
  end

  test "GET /:id" do
    user = create(:user)
    other_user = create(:user)
    note = create(:notification, user: user)

    assert_require_user do
      get notification_path(note.id)
    end

    sign_in other_user
    assert_raise(ActiveRecord::RecordNotFound) do
      get notification_path(note.id)
    end

    sign_in user
    get notification_path(note.id)
    assert_redirected_to note.target_url

    note.reload
    assert_not_nil note.read_at
  end
end
