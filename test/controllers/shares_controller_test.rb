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

        comments.each do |comment|
          assert_select "details#comment-#{comment.id}-menu-button"
          assert_select "clipboard-copy" do
            assert_select "[data-clipboard-text=?]", share.to_url + "#comment-#{comment.id}"
            assert_select "[data-clipboard-tooltip-target=?]", "#comment-#{comment.id}-menu-button"
          end
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
    allow_feature(:reader_list) do
      get share.to_path
    end
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
        assert_react_component "InlineEditor" do |props|
          assert_equal "comment[body_sml]", props[:name]
          assert_equal "comment[body]", props[:markdownName]
          assert_equal "sml", props[:format]
          assert_equal rails_direct_uploads_url, props[:directUploadURL]
          assert_equal upload_path(":id"), props[:blobURLTemplate]
        end
      end
    end

    allow_feature(:reader_list) do
      assert_equal true, user.read_doc?(share.shareable)
    end

    # close share
    share.destroy

    get share.to_path
    assert_equal 404, response.status
  end
end
