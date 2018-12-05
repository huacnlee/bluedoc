# frozen_string_literal: true

require "test_helper"

class SharesControllerTest < ActionDispatch::IntegrationTest
  test "GET /shares/:slug" do
    doc = create(:doc)
    comments = create_list(:comment, 2, commentable: doc)
    share = create(:share, shareable: doc)

    get share.to_path
    assert_equal 200, response.status
    assert_select ".doc-page" do
      assert_select ".doc-title", text: doc.title
      assert_select ".btn-edit-doc", 0
      assert_select ".btn-star-doc", 0
      assert_select ".markdown-body"
      assert_select ".doc-reaction" do
        assert_select ".add-reaction-btn", 0
      end
      assert_select ".comments" do
        assert_select ".comment", 2 do
          assert_select ".add-reaction-btn", 0
        end
      end
      assert_select "form.new_comment", 0
      assert_select "#comment-form-blankslate" do
        assert_select "h2", text: "Sign in to write comment"
      end
    end

    # sign in
    user = create(:user)
    sign_in user
    get share.to_path
    assert_equal 200, response.status
    assert_select ".doc-page" do
      assert_select ".doc-title", text: doc.title
      assert_select ".btn-edit-doc", 0
      assert_select ".btn-star-doc", 0
      assert_select ".markdown-body"
      assert_select ".doc-reaction" do
        assert_select ".add-reaction-btn"
      end
      assert_select ".comments" do
        assert_select ".comment", 2 do
          assert_select ".add-reaction-btn"
        end
      end
      assert_select "#comment-form-blankslate", 0
      assert_select "form.new_comment" do
        assert_select "textarea.form-control"
      end
    end
  end
end