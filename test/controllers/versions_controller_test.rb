# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::OutputSafetyHelper

  setup do
    @user = create(:user)
    @group = create(:group)
    @repo = create(:repository, user: @group)
    @doc = create(:doc, repository: @repo)
  end

  test "GET /versions/:id" do
    create(:version, type: "DocVersion", subject: @doc)
    previous_version = create(:version, type: "DocVersion", subject: @doc)
    current_version = create(:version, type: "DocVersion", subject: @doc)
    create(:version, type: "DocVersion", subject: @doc)

    sign_in_role :reader, group: @group
    get version_path(current_version.id), xhr: true
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    get version_path(current_version.id), xhr: true
    assert_equal 200, response.status
    assert_match %($("input[name=version_id]").val("#{current_version.id}");), response.body
    assert_match %($(".version-item-#{current_version.id}").addClass("selected");), response.body
    assert_match %($(".version-items").data("selected-id", '#{current_version.id}');), response.body
    assert_match %($(".version-preview .markdown-body").html("#{j(raw(current_version.body_html))}");), response.body
    assert_match %($("#previus-version-content").html("#{j(raw(previous_version.body_html))}")), response.body
    assert_match %($(".btn-revert").removeAttr("disabled");), response.body
    assert_match %($(".version-preview").trigger("render:diff");), response.body
  end
end
