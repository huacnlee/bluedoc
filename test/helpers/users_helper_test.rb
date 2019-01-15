# frozen_string_literal: true

require "test_helper"

class UsersHelperTest < ActionView::TestCase
  include ApplicationHelper
  include Webpacker::Helper

  setup do
    @user = create(:user)
  end

  def current_user; @user; end

  test "user_name_tag" do
    assert_equal "", user_name_tag(nil)
    user = build(:user)

    assert_html_equal %(<a class="user-name" title="#{user.fullname}" href="/#{user.slug}">#{user.slug}</a>), user_name_tag(user)
  end

  test "user_display_name_tag" do
    assert_equal "", user_display_name_tag(nil)
    user = build(:user)

    assert_html_equal %(<a class="user-display-name" title="#{user.fullname}" href="/#{user.slug}">#{user.name}</a>), user_display_name_tag(user)
  end

  test "user_avatar_tag" do
    assert_equal "", user_avatar_tag(nil)

    # Attachment Avatar
    user = create(:user)
    user.avatar.attach(io: load_file("blank.png"), filename: "blank.png")
    assert_equal true, user.avatar.attached?
    avatar_url = "https://bar.com/foo.jpg"

    user.stub(:avatar_url, avatar_url) do
      assert_html_equal %(<a class="user-avatar" data-name="#{user.name}" data-slug="#{user.slug}" href="/#{user.slug}"><img class="avatar avatar-small" title="#{user.fullname}" src="#{avatar_url}" /></a>), user_avatar_tag(user, style: :small)
      assert_html_equal %(<img class="avatar avatar-tiny" title="#{user.fullname}" src="#{avatar_url}" />), user_avatar_tag(user, style: :tiny, link: false)
    end

    # Latter Avatar
    user = create(:user, slug: "someone")
    avatar_url = "#{Setting.host}/system/letter_avatars/2/S/162_136_126/240.png"
    assert_html_equal %(<a class="user-avatar" data-name="#{user.name}" data-slug="#{user.slug}" href="/#{user.slug}"><img class="avatar avatar-small" title="#{user.fullname}" src="#{avatar_url}" /></a>), user_avatar_tag(user, style: :small)
    assert_html_equal %(<img class="avatar avatar-tiny" title="#{user.fullname}" src="#{avatar_url}" />), user_avatar_tag(user, style: :tiny, link: false)
  end

  test "follow_user_tag" do
    assert_equal "", follow_user_tag(nil)

    user = create(:user)

    assert_equal %(<a data-id="#{user.slug}" data-label="Follow" data-undo-label="Unfollow" class="btn-follow-user btn btn-block" href="#"><span>Follow</span></a>), follow_user_tag(user)

    @user.stub(:follow_user_ids, [user.id]) do
      assert_equal %(<a data-id="#{user.slug}" data-label="Follow" data-undo-label="Unfollow" class="btn-follow-user btn btn-block active" href="#"><span>Unfollow</span></a>), follow_user_tag(user)
    end
  end
end
