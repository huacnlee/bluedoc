# frozen_string_literal: true

require "test_helper"

class BookLab::RootQueryTest < BookLab::GraphQL::IntegrationTest
  test "hello" do
    execute("{ hello }", context: {})
    assert_equal "Hello", response_data["hello"]

    user = build(:user)
    execute("{ hello }", context: {
      current_user: user
    })
    assert_equal "Hello, #{user.name}", response_data["hello"]
  end
end
