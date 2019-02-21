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
    assert_html_equal %(<a class="user-name" title="#{user.fullname}" data-type="user" href="/#{user.slug}">#{user.name}</a>), user_name_tag(user)
    assert_html_equal %(<a class="user-name icon-middle-wrap" title="#{user.fullname}" data-type="user" href="/#{user.slug}"><i class="fas fa-user "></i><span>#{user.name}</span></a>), user_name_tag(user, with_icon: true)

    group = build(:group)
    assert_html_equal %(<a class="user-name" title="#{group.fullname}" data-type="group" href="/#{group.slug}">#{group.name}</a>), user_name_tag(group)


  end

  test "user_display_name_tag" do
    assert_equal "", user_display_name_tag(nil)
    user = build(:user)
    assert_html_equal %(<a class="user-display-name" title="#{user.fullname}" data-type="user" href="/#{user.slug}">#{user.name}</a>), user_display_name_tag(user)
    assert_html_equal %(<a class="user-display-name icon-middle-wrap" title="#{user.fullname}" data-type="user" href="/#{user.slug}"><i class="fas fa-user "></i><span>#{user.name}</span></a>), user_display_name_tag(user, with_icon: true)

    group = build(:group)
    assert_html_equal %(<a class="user-display-name" title="#{group.fullname}" data-type="group" href="/#{group.slug}">#{group.name}</a>), user_display_name_tag(group)
  end

  test "user_avatar_tag" do
    assert_equal "", user_avatar_tag(nil)

    # Attachment Avatar
    user = create(:user)
    user.avatar.attach(io: load_file("blank.png"), filename: "blank.png")
    assert_equal true, user.avatar_attached?
    avatar_url = "https://bar.com/foo.jpg"

    user.stub(:avatar_url, avatar_url) do
      assert_html_equal %(<a class="user-avatar" data-name="#{user.name}" data-slug="#{user.slug}" data-type="user" href="/#{user.slug}"><img class="avatar avatar-small" title="#{user.fullname}" src="#{avatar_url}" /></a>), user_avatar_tag(user, style: :small)
      assert_html_equal %(<img class="avatar avatar-tiny" title="#{user.fullname}" src="#{avatar_url}" />), user_avatar_tag(user, style: :tiny, link: false)
    end

    # Latter Avatar
    user = create(:user, slug: "someone")
    assert_html_equal %(<a class="user-avatar" data-name="#{user.name}" data-slug="#{user.slug}" data-type="user" href="/#{user.slug}"><span class="default-avatar avatar avatar-small default-avatar-3">S</span></a>), user_avatar_tag(user, style: :small)
    assert_html_equal %(<span class="default-avatar avatar avatar-tiny default-avatar-3">S</span>), user_avatar_tag(user, style: :tiny, link: false)
  end

  test "follow_user_tag" do
    assert_equal "", follow_user_tag(nil)

    user = create(:user)

    assert_equal %(<button data-id="#{user.slug}" data-label="Follow" data-undo-label="Unfollow" class="btn-follow-user btn btn-block" href="#">Follow</button>), follow_user_tag(user)

    @user.stub(:follow_user_ids, [user.id]) do
      assert_equal %(<button data-id="#{user.slug}" data-label="Follow" data-undo-label="Unfollow" class="btn-follow-user btn btn-block active" href="#">Unfollow</button>), follow_user_tag(user)
    end
  end
end
