# frozen_string_literal: true

require "test_helper"

class AutocompletesControllerTest < ActionDispatch::IntegrationTest
  test "users" do
    assert_require_user do
      get users_autocomplete_path, params: { q: "" }
    end

    users = create_list(:user, 3)
    user = users.first
    sign_in user
    User.stub(:prefix_search, users) do
      get users_autocomplete_path, params: { q: "" }
      assert_equal 200, response.status
      assert_select ".autocomplete-item", users.length
      assert_select ".autocomplete-item .avatar-tiny", users.length

      users.each do |u|
        assert_select ".autocomplete-item[data-value=#{u.slug}]", 1
      end
    end
  end

  test "users.json" do
    users = create_list(:user, 3)
    user = users.first
    sign_in user

    User.stub(:prefix_search, users) do
      get users_autocomplete_path, params: { q: "", format: :json }
      assert_equal 200, response.status

      json = JSON.parse(response.body)
      assert_equal users.length, json["users"].length
    end
  end
end
