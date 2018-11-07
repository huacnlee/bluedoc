require 'test_helper'

class BookLab::SlugTest < ActionView::TestCase
  test "valid?" do
    assert_equal true, BookLab::Slug.valid?("hello-world_123.foo")
    assert_equal false, BookLab::Slug.valid?("h1&^21")
  end

  test "slugize" do
    assert_equal "", BookLab::Slug.slugize(nil)
    assert_equal "hello-world", BookLab::Slug.slugize("Hello World")
    assert_equal "hello-world", BookLab::Slug.slugize("Hello@World")
    assert_equal "-hello-world", BookLab::Slug.slugize("*Hello@World")
  end

  test "random" do
    10000.times do
      assert_not_equal BookLab::Slug.random, BookLab::Slug.random
      assert BookLab::Slug.random.length > 3
    end
  end
end
