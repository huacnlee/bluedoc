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
end
