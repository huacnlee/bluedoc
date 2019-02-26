# frozen_string_literal: true

require "test_helper"

class BlueDoc::SlugTest < ActionView::TestCase
  test "valid?" do
    assert_equal true, BlueDoc::Slug.valid?("hello-world_123.foo")
    assert_equal false, BlueDoc::Slug.valid?("h1&^21")

    assert_equal true, BlueDoc::Slug.valid?("user")
    assert_equal true, BlueDoc::Slug.valid?("account")
    assert_equal true, BlueDoc::Slug.valid?("accounts")
  end

  test ".valid_user?" do
    assert_equal true, BlueDoc::Slug.valid_user?("user1")
    assert_equal true, BlueDoc::Slug.valid_user?("foo")

    # keywords
    assert_equal false, BlueDoc::Slug.valid_user?("user")
    assert_equal false, BlueDoc::Slug.valid_user?("USER")
    assert_equal false, BlueDoc::Slug.valid_user?("account")
    assert_equal false, BlueDoc::Slug.valid_user?("Account")
    assert_equal false, BlueDoc::Slug.valid_user?("accounts")
    assert_equal false, BlueDoc::Slug.valid_user?("dashboard")
    assert_equal false, BlueDoc::Slug.valid_user?("settings")

    assert_equal false, BlueDoc::Slug.valid_user?("notes")
  end

  test ".valid_repo?" do
    assert_equal true, BlueDoc::Slug.valid_repo?("user1")
    assert_equal true, BlueDoc::Slug.valid_repo?("foo")

    # keywords
    assert_equal false, BlueDoc::Slug.valid_repo?("note")
    assert_equal false, BlueDoc::Slug.valid_repo?("repositories")
    assert_equal false, BlueDoc::Slug.valid_repo?("notes")
    assert_equal false, BlueDoc::Slug.valid_repo?("NOTE")
  end

  test "slugize" do
    assert_equal "", BlueDoc::Slug.slugize(nil)
    assert_equal "Hello-World", BlueDoc::Slug.slugize("Hello World")
    assert_equal "Hello-World", BlueDoc::Slug.slugize("  Hello World   ")
    assert_equal "Hello-World", BlueDoc::Slug.slugize("Hello@World")
    assert_equal "Hello-World", BlueDoc::Slug.slugize("*^@Hello@World**")
  end

  test "random" do
    10000.times do
      assert_not_equal BlueDoc::Slug.random, BlueDoc::Slug.random
      assert BlueDoc::Slug.random.length > 3
    end
  end
end
