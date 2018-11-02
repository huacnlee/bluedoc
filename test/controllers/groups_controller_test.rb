require 'test_helper'

class GroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
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
    assert_match /Username has already been taken/, response.body
  end
end
