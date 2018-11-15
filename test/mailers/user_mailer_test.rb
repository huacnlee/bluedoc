require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "welcome" do
    user = create(:user)

    mail = UserMailer.with(user: user).welcome

    assert_emails 1 do
      mail.deliver_now
    end

    assert_equal [user.email], mail.to
    assert_equal "Welcome to use BookLab", mail.subject
    assert_match /Hi, #{user.name}/, mail.body.to_s
  end

  test "added_to_group" do
    user = create(:user)
    group = create(:group)
    actor = create(:user)

    mail = UserMailer.with(user: user, group: group, actor: actor).added_to_group

    assert_emails 1 do
      mail.deliver_now
    end

    assert_equal [user.email], mail.to
    assert_equal "#{actor.name} has added you as #{group.name}'s member", mail.subject
    assert_match /Hi, #{user.name}/, mail.body.to_s
  end
end
