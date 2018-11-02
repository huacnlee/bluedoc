# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @group = create(:group)
    @repo = create(:repository, user: @group)
    @doc = create(:doc, repository: @repo)
  end

  test "GET /versions/:id" do
    version = @doc.versions.first

    sign_in_role :reader, group: @group
    get version_path(version.id), xhr: true
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    get version_path(version.id), xhr: true
    assert_equal 200, response.status
    assert_match %($("input[name=version_id]").val("#{version.id}");), response.body
    assert_match %($(".version-item-#{version.id}").addClass("selected");), response.body
  end
end
