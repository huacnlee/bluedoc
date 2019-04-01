# frozen_string_literal: true

require "test_helper"

class LabelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group = create(:group)
    @repository = create(:repository, user: @group)
  end

  test "GET /:user/:repo/labels" do
    assert_require_user do
      get @repository.to_path("/issues/labels")
    end

    user = create(:user)
    sign_in user
    get @repository.to_path("/issues/labels")
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    get @repository.to_path("/issues/labels")
    assert_equal 403, response.status

    sign_in_role :admin, group: @group
    get @repository.to_path("/issues/labels")
    assert_equal 200, response.status

    assert_select ".label-list" do
      assert_react_component "labels/Label"
    end
  end
  test "POST /:user/:repo/issues/labels" do
    assert_require_user do
      post @repository.to_path("/issues/labels")
    end

    user = create(:user)
    sign_in user

    label_params = {
      title: "Hello world",
      color: "#000000",
    }

    post @repository.to_path("/issues/labels"), params: { label: label_params }
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    post @repository.to_path("/issues/labels"), params: { label: label_params }
    assert_equal 403, response.status

    sign_in_role :admin, group: @group
    post @repository.to_path("/issues/labels"), params: { label: label_params }
    assert_equal 200, response.status
    json = JSON.parse(response.body)
    assert_equal true, json["ok"]

    label = @repository.issue_labels.last
    assert_equal label_params[:title], label.title
    assert_equal label_params[:color], label.color

    post @repository.to_path("/issues/labels"), params: { label: { title: "" } }
    assert_equal 200, response.status
    json = JSON.parse(response.body)
    assert_equal false, json["ok"]
    assert_equal "Title can't be blank", json["errors"]
  end

  test "PUT /:user/:repo/issues/labels/:id" do
    label = create(:label, target: @repository)
    assert_require_user do
      put @repository.to_path("/issues/labels/#{label.id}")
    end

    user = create(:user)
    sign_in user

    label_params = {
      title: "Hello world",
      color: "#000000",
    }

    put @repository.to_path("/issues/labels/#{label.id}"), params: { label: label_params }
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    put @repository.to_path("/issues/labels/#{label.id}"), params: { label: label_params }
    assert_equal 403, response.status

    sign_in_role :admin, group: @group
    put @repository.to_path("/issues/labels/#{label.id}"), params: { label: label_params }
    assert_equal 200, response.status
    json = JSON.parse(response.body)
    assert_equal true, json["ok"]

    label.reload
    assert_equal label_params[:title], label.title
    assert_equal label_params[:color], label.color

    put @repository.to_path("/issues/labels/#{label.id}"), params: { label: { color: "1" } }
    assert_equal 200, response.status
    json = JSON.parse(response.body)
    assert_equal false, json["ok"]
    assert_equal "Color Invalid color format", json["errors"]
  end

  test "DELETE /:user/:repo/issues/labels/:id" do
    label = create(:label, target: @repository)
    assert_require_user do
      delete @repository.to_path("/issues/labels/#{label.id}")
    end

    user = create(:user)
    sign_in user

    delete @repository.to_path("/issues/labels/#{label.id}")
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    delete @repository.to_path("/issues/labels/#{label.id}")
    assert_equal 403, response.status

    sign_in_role :admin, group: @group
    delete @repository.to_path("/issues/labels/#{label.id}")
    assert_equal 200, response.status
    json = JSON.parse(response.body)
    assert_equal true, json["ok"]

    assert_equal 0, Label.where(id: label.id).count
  end
end
