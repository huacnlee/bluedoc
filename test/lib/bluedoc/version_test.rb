# frozen_string_literal: true

require "test_helper"

class BlueDoc::VersionTest < ActionView::TestCase
  test "full_version" do
    assert_match BlueDoc::VERSION, BlueDoc.full_version

    ENV["BLUEDOC_BUILD_VERSION"] = "123"
    assert_equal "#{BlueDoc::VERSION} (build 123)", BlueDoc.full_version
  end
end