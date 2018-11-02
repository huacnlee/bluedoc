require 'test_helper'

class BookLab::SlugTest < ActionView::TestCase
  test ".valid?" do
    assert_equal true, BookLab::Slug.valid?("hello-world_123.foo")
    assert_equal false, BookLab::Slug.valid?("h1&^21")
  end
end
