require 'test_helper'

class GroupSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group = create(:group)
  end

  test "GET /groups/settings" do
    get group_settings_path(@group)
    assert_equal 403, response.status

    sign_in_user
    get group_settings_path(@group)
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    get group_settings_path(@group)
    assert_equal 403, response.status

    sign_in_role :admin, group: @group
    get group_settings_path(@group)
    assert_equal 200, response.status
    assert_match /group-settings/, response.body
    assert_match /Danger zone/, response.body
  end

  test "PUT /groups/settings" do
    group_params = {
      name: "New #{@group.name}",
      url: "#{@group.url}/new",
      slug: "#{@group.slug}-new",
      description: "New #{@group.description}",
      location: "New #{@group.location}"
    }

    put group_settings_path(@group), params: { group: group_params }
    assert_equal 403, response.status

    sign_in_user
    put group_settings_path(@group), params: { group: group_params }
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    put group_settings_path(@group), params: { group: group_params }
    assert_equal 403, response.status

    sign_in_role :admin, group: @group
    put group_settings_path(@group), params: { group: group_params }
    @group.reload
    assert_redirected_to group_settings_path(@group)

    assert_equal group_params[:name], @group.name
    assert_equal group_params[:slug], @group.slug
    assert_equal group_params[:url], @group.url
    assert_equal group_params[:description], @group.description
    assert_equal group_params[:location], @group.location
  end

  test "DELETE /groups/settings" do
    delete group_settings_path(@group)
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    delete group_settings_path(@group)
    assert_equal 403, response.status

    sign_in_role :admin, group: @group
    delete group_settings_path(@group)
    assert_redirected_to root_path
    group = Group.find_by_id(@group.id)
    assert_nil group
  end
end
