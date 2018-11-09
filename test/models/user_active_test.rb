# frozen_string_literal: true

require "test_helper"

class UserActiveTest < ActiveSupport::TestCase
  test ".track" do
    user = create(:user)
    repo0 = create(:repository)
    repo1 = create(:repository)
    doc = create(:doc)
    group = create(:group)

    Time.stub(:now, 1.hours.ago) do
      UserActive.track(repo0, user_id: user.id)
      UserActive.track(repo1, user: user)
      UserActive.track(doc, user: user)
      UserActive.track(group, user: user)
    end
    sleep 0.01
    UserActive.track(repo0, user_id: user.id)
    sleep 0.01
    UserActive.track(doc, user_id: user.id)

    assert_equal 4, user.user_actives.count
    assert_equal 2, user.user_actives.where(subject_type: "Repository").count
    assert_equal 1, user.user_actives.where(subject: repo0).count
    assert_equal 1, user.user_actives.where(subject: repo1).count
    assert_equal 1, user.user_actives.where(subject: doc).count
    assert_equal 1, user.user_actives.where(subject: group).count
    assert_equal doc, user.user_actives.first.subject
    assert_equal repo0, user.user_actives.second.subject
  end

  test ".track avoid User type" do
    user = create(:user)

    user0 = create(:user)
    UserActive.track(user0, user: user)
    assert_equal 0, user.user_actives.count

    group = create(:group)
    UserActive.track(group, user: user)
    assert_equal 1, user.user_actives.count
  end

  test "scopes" do
    user = create(:user)
    doc0 = create(:doc)
    doc1 = create(:doc)
    UserActive.track(doc0, user: user)
    UserActive.track(doc1, user: user)
    UserActive.track(doc0.repository, user: user)
    UserActive.track(doc1.repository, user: user)
    UserActive.track(doc0.repository.user, user: user)
    UserActive.track(doc1.repository.user, user: user)

    # with_user(user).docs
    assert_equal 2, UserActive.with_user(user).docs.count
    docs = UserActive.with_user(user).docs.collect(&:subject)
    assert_equal true, docs.include?(doc0)
    assert_equal true, docs.include?(doc1)

    # with_user(user).repositories
    assert_equal 2, UserActive.with_user(user).repositories.count
    repositories = UserActive.with_user(user).repositories.collect(&:subject)
    assert_equal true, repositories.include?(doc0.repository)
    assert_equal true, repositories.include?(doc1.repository)

    # with_user(user).groups
    assert_equal 2, UserActive.with_user(user).groups.count
    groups = UserActive.with_user(user).groups.collect(&:subject)
    assert_equal true, groups.include?(doc0.repository.user)
    assert_equal true, groups.include?(doc1.repository.user)
  end
end
