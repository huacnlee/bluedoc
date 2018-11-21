# frozen_string_literal: true

require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @doc = create(:doc)
  end

  test "GET /comments via Doc" do
    comments = create_list(:comment, 3, user: @user, commentable: @doc)

    get @doc.to_path
    assert_equal 200, response.status
    assert_select ".doc-comments .comments .comment", 3
    comments.each do |c|
      assert_select "#comment-#{c.id}" do
        assert_select ".markdown-body", html: c.body_html
        assert_select "a[data-method=delete]", 0
      end
    end

    sign_in @user
    get @doc.to_path
    assert_equal 200, response.status
    assert_select ".doc-comments .comments" do
      assert_select ".comment a[data-method=delete]", 3
    end
  end

  test "POST /comments with public commentable" do
    comment_params = {
      commentable_type: "Doc",
      commentable_id: @doc.id,
      body: "hello world"
    }

    post comments_path, params: { comment: comment_params }, xhr: true
    assert_equal 401, response.status

    sign_in @user
    post comments_path, params: { comment: comment_params }, xhr: true
    assert_equal 200, response.status
    assert_match %($('.comments').append(html);), response.body
    assert_match %($('.new_comment [name="comment[body]"]').val('');), response.body

    assert_equal 1, @doc.comments.count
    comment = @doc.comments.last
    assert_equal @user.id, comment.user_id
    assert_nil comment.parent_id
    assert_equal comment_params[:body], comment.body
  end

  test "POST /comments with private commentable" do
    group = create(:group)
    repo = create(:repository, user: group, privacy: :private)
    doc = create(:doc, repository: repo)

    comment_params = {
      commentable_type: "Doc",
      commentable_id: doc.id,
      body: "hello world"
    }

    sign_in @user
    post comments_path, params: { comment: comment_params }, xhr: true
    assert_equal 403, response.status

    sign_in_role :reader, group: group
    post comments_path, params: { comment: comment_params }, xhr: true
    assert_equal 200, response.status
    assert_equal 1, doc.comments.count
  end

  test "GET /comments/:id/reply" do
    comment = create(:comment)

    get reply_comment_path(comment.id), xhr: true
    assert_equal 401, response.status

    sign_in @user
    get reply_comment_path(comment.id), xhr: true
    assert_equal 200, response.status
    assert_match %($(".new_comment .in-reply-info").html), response.body
  end

  test "GET /comments/:id/in_reply" do
    comment = create(:comment)

    get in_reply_comment_path(comment.id), xhr: true
    assert_equal 200, response.status
    assert_match %($("#comment-#{comment.id} .in-reply-to")), response.body
    assert_no_match %(<div class="in-reply-link">), response.body

    comment1 = create(:comment, parent: comment)
    get in_reply_comment_path(comment1.id), xhr: true
    assert_equal 200, response.status
    assert_match %($("#comment-#{comment1.id} .in-reply-to")), response.body
    assert_match %(<div class=\\"in-reply-link\\">), response.body
  end

  test "PUT /comments/:id" do
    comment = create(:comment)

    comment_params = {
      parent_id: comment.id,
      user_id: 1111,
      body: "New body"
    }

    put comment_path(comment.id), params: { comment: comment_params }, xhr: true
    assert_equal 401, response.status

    sign_in @user
    put comment_path(comment.id), params: { comment: comment_params }, xhr: true
    assert_equal 403, response.status

    comment = create(:comment, user_id: @user.id)
    put comment_path(comment.id), params: { comment: comment_params }, xhr: true
    assert_equal 200, response.status
    assert_match %($("#comment-#{comment.id}").replaceWith), response.body

    comment.reload
    assert_equal comment_params[:body], comment.body
    assert_equal @user.id, comment.user_id
    assert_nil comment.parent_id
  end

  test "DELETE /comments/:id" do
    user = create(:user)
    comment = create(:comment, user: user)

    delete comment_path(comment.id), xhr: true
    assert_equal 401, response.status

    sign_in @user
    delete comment_path(comment.id), xhr: true
    assert_equal 403, response.status

    sign_in user
    delete comment_path(comment.id), xhr: true
    assert_equal 200, response.status
    assert_match %($('#comment-#{comment.id}').remove), response.body

    assert_nil Comment.find_by_id(comment.id)
  end
end