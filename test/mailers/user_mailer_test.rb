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

  test "add_member of Group" do
    user = create(:user)
    group = create(:group)
    actor = create(:user)
    member = create(:member, subject: group)

    mail = UserMailer.with(user: user, member: member, actor: actor).add_member

    assert_emails 1 do
      mail.deliver_now
    end

    assert_equal [user.email], mail.to
    assert_equal "#{actor.name} has added you as #{group.name}'s member", mail.subject
    assert_match /Hi, #{user.name}/, mail.body.to_s
    assert_match %(href="#{Setting.host}/#{group.slug}"), mail.body.to_s
  end

  test "add_member of Repository" do
    user = create(:user)
    group = create(:group)
    repo = create(:repository, user: group)
    actor = create(:user)
    member = create(:member, subject: repo)

    mail = UserMailer.with(user: user, member: member, actor: actor).add_member

    assert_emails 1 do
      mail.deliver_now
    end

    assert_equal [user.email], mail.to
    assert_equal "#{actor.name} has added you as #{repo.name}'s member", mail.subject
    assert_match /Hi, #{user.name}/, mail.body.to_s
    assert_match %(href="#{Setting.host}/#{group.slug}/#{repo.slug}"), mail.body.to_s
  end
end
