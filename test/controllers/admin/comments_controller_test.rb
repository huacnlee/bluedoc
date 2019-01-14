# frozen_string_literal: true

require "test_helper"

class Admin::CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user)
    sign_in_admin @admin

    @comment = create(:comment)
  end

  test "should get index" do
    get admin_comments_path
    assert_equal 200, response.status
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
