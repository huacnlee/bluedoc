# frozen_string_literal: true

require "test_helper"

class GroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "GET /:username" do
    @group = create(:group)
    create(:repository, user: @group, name: "Test Foo")
    create(:repository, user: @group, name: "Test Bar")

    get @group.to_path
    assert_equal 200, response.status
    assert_match /#{@group.name}/, response.body
    assert_select ".group-avatar-box"
    assert_select ".group-repositories"
    assert_select ".group-repositories .repository-item", 2
    assert_react_component "navbar/Search" do |props|
      assert_equal search_group_path(@group), props[:action]
      assert_equal "Group", props[:scope]
      assert_nil props[:value]
    end

    # with anonymous disable
    Setting.stub(:anonymous_enable?, false) do
      assert_require_user do
        get @group.to_path
      end
    end

    get @group.to_path, params: { q: "bar" }
    assert_equal 200, response.status
    assert_select ".group-repositories .repository-item", 1
    assert_select ".subnav-search input.subnav-search-input" do
      assert_select "[value=?]", "bar"
    end
    assert_select ".subnav-search a.link-cancel" do
      assert_select "[href=?]", @group.to_path
    end

    # validate repositories get
    @group = create(:group)
    create_list(:repository, 2, user: @group, privacy: :public)
    private_repo = create(:repository, user: @group, privacy: :private)
    get @group.to_path
    assert_select ".repository-item", 2

    sign_in @user
    get @group.to_path
    assert_select ".repository-item", 2

    sign_in_role :reader, group: @group
    get @group.to_path
    assert_select ".repository-item", 3
    assert_match /#{private_repo.name}/, response.body

    sign_in_role :editor, group: @group
    get @group.to_path
    assert_select ".repository-item", 3
    assert_match /#{private_repo.name}/, response.body
  end

  test "GET /groups/new" do
    assert_require_user do
      get "/groups/new"
    end

    sign_in @user
    get "/groups/new"
    assert_equal 200, response.status
    assert_match /New Group/, response.body
  end

  test "POST /groups" do
    g = build(:group)
    group_params = { name: g.name, slug: g.slug }
    assert_require_user do
      post "/groups", params: { group: group_params }
    end

    sign_in @user
    post "/groups", params: { group: group_params }
    assert_redirected_to "/#{group_params[:slug]}"

    group = Group.find_by_slug(group_params[:slug])
    assert_not_nil group
    assert_equal group_params[:name], group.name
    assert_equal "", group.email

    post "/groups", params: { group: group_params }
    assert_equal 200, response.status
    assert_match /Group name has already been taken/, response.body
  end

  test "GET /groups/:pathname/search" do
    @group = create(:group)

    get search_group_path(@group)
    assert_redirected_to @group.to_path

    get search_group_path(@group), params: { q: "test" }
    assert_equal 200, response.status
    assert_select ".reponav-item.selected" do
      assert_select "[href=?]", search_group_path(@group)
    end
  end
end
