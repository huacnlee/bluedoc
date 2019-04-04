# frozen_string_literal: true

require "test_helper"

class Queries::RootQueryTest < BlueDoc::GraphQL::IntegrationTest
  test "hello" do
    execute("{ hello }")
    assert_equal "Hello", response_data["hello"]

    user = build(:user)
    sign_in user
    execute("{ hello }")
    assert_equal "Hello, #{user.name}", response_data["hello"]
  end
end
