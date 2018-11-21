require 'test_helper'

class NotificationMailerTest < ActionMailer::TestCase
  test "add_member" do
    user = create(:user)
    group = create(:group)
    actor = create(:user)
    member = create(:member, subject: group)
    note = create(:notification, notify_type: "add_member", target: member)

    mail = NotificationMailer.with(notification: note).to_user

    assert_emails 1 do
      mail.deliver_now
    end

    assert_equal [note.email], mail.to
    assert_equal note.text, mail.subject
    assert_match note.html, mail.body.to_s
    assert_match %(href="#{Setting.host}/notifications/#{note.id}"), mail.body.to_s
  end

  test "comment" do
    comment = create(:comment)
    note = create(:notification, notify_type: "comment", target: comment)
    mail = NotificationMailer.with(notification: note).to_user

    assert_emails 1 do
      mail.deliver_now
    end

    assert_equal [note.email], mail.to
    assert_equal note.text, mail.subject
    assert_match comment.body_html, mail.body.to_s
    assert_match %(href="#{Setting.host}/notifications/#{note.id}"), mail.body.to_s
  end
end