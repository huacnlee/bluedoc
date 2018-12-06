# frozen_string_literal: true

require "test_helper"

class BookLab::ValidateTest < ActiveSupport::TestCase
  test "url?" do
    assert_equal true, BookLab::Validate.url?("http://foo")
    assert_equal true, BookLab::Validate.url?("https://foo")
    assert_equal false, BookLab::Validate.url?("/http/bar")
  end
end
