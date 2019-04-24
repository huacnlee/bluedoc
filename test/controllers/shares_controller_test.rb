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

      assert_react_component "comments/Index" do |props|
        assert_nil props[:currentUser]
        assert_equal "Doc", props[:commentableType]
        assert_equal doc.id, props[:commentableId]
        assert_equal "unwatch", props[:watchStatus]
        assert_equal false, props[:abilities][:update]
        assert_equal false, props[:abilities][:destroy]
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
      assert_react_component "reactions/Index" do |props|
        assert_equal "Doc", props[:subjectType]
        assert_equal doc.id, props[:subjectId]
        assert_equal doc.reactions_as_json.sort, props[:reactions].sort
      end

      assert_react_component "comments/Index" do |props|
        assert_equal user.as_json(only: %i[id slug name avatar_url]), props[:currentUser].deep_stringify_keys
        assert_equal "Doc", props[:commentableType]
        assert_equal doc.id, props[:commentableId]
        assert_equal "unwatch", props[:watchStatus]
        assert_equal false, props[:abilities][:update]
        assert_equal false, props[:abilities][:destroy]
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
