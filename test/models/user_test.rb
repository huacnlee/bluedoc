# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "base" do
    exist_user = create(:user, name: nil)

    user = build(:user, slug: exist_user.slug, name: nil)
    assert_equal false, user.valid?

    user = build(:user, slug: "Jason Lee", name: nil)
    assert_equal false, user.valid?

    user = build(:user, slug: "Jason-Lee_123", name: nil)
    assert_equal true, user.valid?

    user = build(:user, slug: "Jason", name: nil)
    assert_equal true, user.valid?

    user.save
    assert_equal false, user.new_record?
    assert_equal "jason", user.slug
    assert_equal user.slug, user.to_param
    assert_equal "jason", user.name
  end

  test "find_by_slug" do
    create(:user, slug: "huacnlee")

    user = User.find_by_slug("huacnlee")
    assert_not_nil user

    assert_equal user, User.find_by_slug!("huacnlee")

    assert_nil User.find_by_slug("huacnlee1")
    assert_raise(ActiveRecord::RecordNotFound) { User.find_by_slug!("huacnlee1") }
  end

  test "to_path" do
    user = build(:user)
    assert_equal "/#{user.slug}", user.to_path
  end

  test "avatar_url" do
    user = create(:user)
    assert_match /\/images\/default-user-/, user.avatar_url
    group = create(:group)
    assert_match /\/images\/default-group-/, group.avatar_url
  end

  test "Groupable" do
    user = User.new
    assert_equal true, user.user?
    assert_equal false, user.group?

    group = Group.new
    assert_equal true, group.group?
    assert_equal false, group.user?
    assert_equal false, group.password_required?
    assert_equal false, group.email_required?
  end

  test "Prefix Search" do
    u0 = create(:user, slug: "jason")
    g0 = create(:group, slug: "jason-group")
    u1 = create(:user, name: "Jason")
    u2 = create(:user, email: "jason@com.com")
    u3 = create(:user, email: "Fooo@bar.com")

    users = User.prefix_search("ja")
    assert_equal 3, users.length
    ids = users.collect(&:id)
    assert_equal [u0.id, u1.id, u2.id].sort, ids.sort
  end

  test "destroy dependent :user_actives and :group_actives" do
    user0 = create(:user)
    user1 = create(:user)
    group = create(:group)

    UserActive.track(group, user: user0)
    UserActive.track(group, user: user1)
    assert_equal 1, UserActive.where(user_id: user0.id).count
    assert_equal 2, UserActive.where(subject_type: "User", subject_id: group.id).count

    user0.destroy
    assert_equal 0, UserActive.where(user_id: user0.id).count

    group.destroy
    assert_equal 0, UserActive.where(subject_type: "User", subject_id: group.id).count
  end

  test ".find_for_database_authentication" do
    user = create(:user, slug: "huacnlee", email: "huacnlee@gmail.com")
    assert_equal user, User.find_for_database_authentication({ email: "huacnlee" })
    assert_equal user, User.find_for_database_authentication({ email: "huacnlee@gmail.com" })

    user = create(:user, slug: "Jason", email: "JASON@Gmail.com")
    assert_equal user, User.find_for_database_authentication({ email: "jason" })
    assert_equal user, User.find_for_database_authentication({ email: "jason@gmail.com" })
  end
end
