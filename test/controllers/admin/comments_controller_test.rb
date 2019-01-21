# frozen_string_literal: true

require "test_helper"

class Admin::CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user)
    sign_in_admin @admin

    @comment = create(:comment)
  end

  test "should get index" do
    @doc = create(:doc)
    comments = create_list(:comment, 3, user: @admin, commentable: @doc)

    private_repo = create(:repository, privacy: :private)
    private_doc = create(:doc, repository: private_repo)
    private_comment = create(:comment, commentable: private_doc)

    get admin_comments_path
    assert_equal 200, response.status

    assert_select ".comments" do
      assert_select ".comment", 5
      assert_select ".comment.hide-comment" do
        assert_select ".markdown-body", text: "Private contents, hide comment."
        assert_select ".opts a", 0
      end
      assert_select ".comment .opts a.btn-edit", 4
    end
  end

  test "should get edit" do
    get edit_admin_comment_path(@comment.id)
    assert_equal 200, response.status
  end

  test "should update admin_comment" do
    comment_params = {
      body: "New body"
    }
    patch admin_comment_path(@comment.id), params: { comment: comment_params }
    assert_redirected_to admin_comments_path

    @comment.reload
    assert_equal "New body", @comment.body
  end

  test "should destroy admin_comment" do
    assert_difference("Comment.count", -1) do
      delete admin_comment_path(@comment.id), xhr: true
    end
    assert_equal 200, response.status
    assert_match %($("#comment-#{@comment.id}").fadeOut().remove()), response.body
  end
end
