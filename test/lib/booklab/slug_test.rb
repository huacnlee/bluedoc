# frozen_string_literal: true

require "test_helper"

class BookLab::SlugTest < ActionView::TestCase
  test "valid?" do
    assert_equal true, BookLab::Slug.valid?("hello-world_123.foo")
    assert_equal false, BookLab::Slug.valid?("h1&^21")

    assert_equal true, BookLab::Slug.valid?("user")
    assert_equal true, BookLab::Slug.valid?("account")
    assert_equal true, BookLab::Slug.valid?("accounts")
  end

  test ".valid_user?" do
    assert_equal true, BookLab::Slug.valid_user?("user1")
    assert_equal true, BookLab::Slug.valid_user?("foo")

    # keywords
    assert_equal false, BookLab::Slug.valid_user?("user")
    assert_equal false, BookLab::Slug.valid_user?("USER")
    assert_equal false, BookLab::Slug.valid_user?("account")
    assert_equal false, BookLab::Slug.valid_user?("Account")
    assert_equal false, BookLab::Slug.valid_user?("accounts")
    assert_equal false, BookLab::Slug.valid_user?("dashboard")
    assert_equal false, BookLab::Slug.valid_user?("settings")
  end

  test "slugize" do
    assert_equal "", BookLab::Slug.slugize(nil)
    assert_equal "Hello-World", BookLab::Slug.slugize("Hello World")
    assert_equal "Hello-World", BookLab::Slug.slugize("  Hello World   ")
    assert_equal "Hello-World", BookLab::Slug.slugize("Hello@World")
    assert_equal "-Hello-World", BookLab::Slug.slugize("*Hello@World")
  end

  test "random" do
    10000.times do
      assert_not_equal BookLab::Slug.random, BookLab::Slug.random
      assert BookLab::Slug.random.length > 3
    end
  end
end
