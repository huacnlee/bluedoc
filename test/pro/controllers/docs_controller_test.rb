# frozen_string_literal: true

require "test_helper"

class Pro::DocsControllerTest < ActionDispatch::IntegrationTest
  test "GET /:user/:repo/:slug with readers" do
    doc = create(:doc)

    user = create(:user)
    users = create_list(:user, 8)

    allow_feature(:reader_list) do
      users.map { |u| u.read_doc(doc) }
    end

    sign_in user

    get doc.to_path
    assert_equal 200, response.status
    assert_select ".doc-readers", 0

    allow_feature(:reader_list) do
      get doc.to_path
      assert_equal 200, response.status
      assert_select ".doc-readers" do
        assert_select "a.readers-link .avatar", 5
      end
    end
  end

  test "GET /:user/:repo/:slug/readers" do
    doc = create(:doc)
    users = create_list(:user, 8)
    allow_feature(:reader_list) do
      users.map { |u| u.read_doc(doc) }
    end

    assert_check_feature do
      get doc.to_path("/readers"), xhr: true
    end

    allow_feature(:reader_list) do
      get doc.to_path("/readers"), xhr: true
      assert_equal 200, response.status

      assert_match %(document.querySelector(".doc-readers").outerHTML = ), response.body
    end
  end
end