# frozen_string_literal: true

require "test_helper"

class BlobsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @file = load_file("blank.png")
    # Get checksum for style processor validation
    checksum = Digest::MD5.file(@file).base64digest
    @blob = create(:blob, checksum: checksum)
    @filename = BlueDoc::Blob.path_for(@blob.key)
    FileUtils.mkdir_p File.dirname(@filename)
    FileUtils.copy_file Rails.root.join("test/factories/blank.png"), @filename
  end

  teardown do
    FileUtils.rm_f @filename
  end

  test "GET /uploads/:id" do
    assert_equal false, @blob.new_record?

    BlueDoc::Blob.stub(:service_name, "Disk") do
      get upload_path(@blob.key)
    end
    assert_equal 200, response.status
    assert_equal @blob.content_type, response.content_type
    assert_equal %(inline; filename="test.png"; filename*=UTF-8''test.png), response.headers["Content-Disposition"]
  end

  test "GET /uploads/:id?s=small" do
    BlueDoc::Blob.stub(:service_name, "Disk") do
      get upload_path(@blob.key, s: "small")
    end
    assert_equal 200, response.status
    assert_equal @blob.content_type, response.content_type
    assert_equal %(inline; filename="test.png"; filename*=UTF-8''test.png), response.headers["Content-Disposition"]
  end
end
