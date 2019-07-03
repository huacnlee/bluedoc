# frozen_string_literal: true

require "test_helper"

class BlueDoc::Export::BaseTest < ActiveSupport::TestCase
  setup do
    @repo = create(:repository)
  end

  test "Base" do
    exporter = BlueDoc::Export::Archive.new(repository: @repo)
    assert_equal @repo, exporter.repository

    assert_equal Rails.root.join("tmp", "BlueDoc::Export::Archive"), exporter.tmp_path
    assert_equal true, Dir.exist?(exporter.tmp_path)
    assert_equal true, exporter.repo_dir.start_with?(exporter.tmp_path.to_s)
  end
end
