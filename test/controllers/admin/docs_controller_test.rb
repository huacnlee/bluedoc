# frozen_string_literal: true

require "test_helper"

class Admin::DocsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user)
    sign_in_admin @admin

    @doc = create(:doc)
  end

  test "should get index" do
    get admin_docs_path
    assert_equal 200, response.status
  end

  test "should show admin_doc" do
    get admin_doc_path(@doc.id)
    assert_equal 200, response.status
  end

  test "should get edit" do
    get edit_admin_doc_path(@doc.id)
    assert_equal 200, response.status
  end

  test "should update admin_doc" do
    doc_params = {
      title: "new title"
    }
    patch admin_doc_path(@doc.id), params: { doc: doc_params }
    assert_redirected_to admin_docs_path
  end

  test "should destroy admin_doc" do
    assert_difference("Doc.count", -1) do
      delete admin_doc_path(@doc.id)
    end

    @doc.reload
    assert_redirected_to admin_docs_path(repository_id: @doc.repository_id, q: @doc.slug)
  end

  test "should restore admin_doc" do
    @doc.destroy
    assert_difference("Doc.count", +1) do
      post restore_admin_doc_path(@doc.id)
    end
    @doc.reload
    assert_redirected_to admin_docs_path(repository_id: @doc.repository_id, q: @doc.slug)

    doc = Doc.find(@doc.id)
    assert_equal false, doc.deleted?
  end
end
