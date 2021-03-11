# frozen_string_literal: true

require "test_helper"

class GraphQLControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "POST /graphql" do
    doc = create(:doc)
    query = %| { doc(id: #{doc.id}) { id,slug,title,body,bodySml,bodyHtml } } |
    post "/graphql", params: {query: query}
    assert_equal 200, response.status
    response_data = JSON.parse(response.body)["data"]
    assert_not_nil response_data
    assert_equal doc.id, response_data["doc"]["id"]
    assert_equal doc.slug, response_data["doc"]["slug"]
  end
end
