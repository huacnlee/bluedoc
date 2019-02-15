# frozen_string_literal: true

require "test_helper"

class BlueDoc::ValidateTest < ActiveSupport::TestCase
  test "url?" do
    assert_equal true, BlueDoc::Validate.url?("http://foo")
    assert_equal true, BlueDoc::Validate.url?("https://foo")
    assert_equal false, BlueDoc::Validate.url?("/http/bar")
  end
end
