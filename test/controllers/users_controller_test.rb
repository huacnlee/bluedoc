# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "GET /:slug" do

    get user_path(@user)
    assert_equal 200, response.status
    assert_match /#{@user.name}/, response.body
    assert_select ".user-overview"

    create_list(:activity, 5, actor_id: @user.id, user_id: nil)

    get user_path(@user)
    assert_equal 200, response.status
    assert_select ".user-activities .activity-item", 5
    assert_select ".user-activities .more-button"

    get user_path(@user), xhr: true
    assert_equal 200, response.status
    assert_match '$(".user-activities form.more-button")', response.body
  end

  test "GET /:slug?tab=repositories" do
    get user_path(@user), params: { tab: "repositories" }
    assert_equal 200, response.status
    assert_match /#{@user.name}/, response.body
    assert_select ".user-repositories"

    # this user has 3 repositories, 2 public, 1 private
    @repos = create_list(:repository, 2, user: @user, privacy: :public)
    @private_repo = create(:repository, user: @user, privacy: :private)

    # validate repositories get
    get user_path(@user), params: { tab: "repositories" }
    assert_equal 200, response.status
    assert_select ".repository-item", 2
    assert_no_match /#{@private_repo.name}/, response.body

    sign_in @user
    get user_path(@user), params: { tab: "repositories" }
    assert_equal 200, response.status
    assert_select ".repository-item", 3
    assert_match /#{@private_repo.name}/, response.body
  end

  test "GET /:slug?tab=stars" do
    get user_path(@user), params: { tab: "stars" }
    assert_equal 200, response.status
    assert_select ".blankslate"


    group = create(:group)
    group.add_member(@user, :editor)
    private_repo0 = create(:repository, user: @user, privacy: :private)
    private_repo1 = create(:repository, user: group, privacy: :private)


    @user.star_repository create(:repository)
    @user.star_repository create(:repository)
    @user.star_repository private_repo0
    @user.star_repository private_repo1

    get user_path(@user), params: { tab: "stars" }
    assert_match /class="user-stars"/, response.body
    assert_select ".repository-item", 2
    assert_no_match /#{private_repo0.name}/, response.body
    assert_no_match /#{private_repo1.name}/, response.body

    sign_in @user
    get user_path(@user), params: { tab: "stars" }
    assert_select ".repository-item", 4
    assert_match /#{private_repo0.name}/, response.body
    assert_match /#{private_repo1.name}/, response.body
  end

  test "GET /:slug?tab=followers" do
    user1 = create(:user)
    user2 = create(:user)

    user1.follow_user(@user)
    user2.follow_user(@user)


    get user_path(@user), params: { tab: "followers" }
    assert_equal 200, response.status
    assert_select ".user-followers"
    assert_select ".user-followers .user-item", 2
  end

  test "GET /:slug?tab=following" do
    user1 = create(:user)
    user2 = create(:user)

    @user.follow_user(user1)
    @user.follow_user(user2)

    get user_path(@user), params: { tab: "following" }
    assert_equal 200, response.status
    assert_select ".user-following"
    assert_select ".user-following .user-item", 2
  end
end
